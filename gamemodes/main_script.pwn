#include <a_samp>
#include <a_players>

// =============================================================================
//                           DIMOND PLAY RP CONFIGURATION
// =============================================================================

// Define Player Roles & Factions
#define FACTION_CITIZEN      0
#define FACTION_POLICE       1
#define FACTION_GOVERNMENT   2
#define FACTION_OCG          3
#define FACTION_EMS          4
#define FACTION_MECHANIC     5
#define FACTION_NEWS         6
#define TOTAL_FACTIONS       7

// Player Variable Data Structure
enum pInfo {
    pAdminLevel,   // Levels 0 to 30 (30 is Founder)
    pFaction,      // Faction IDs 0 to 6
    pFactionRank,  // Ranks 1 to 10 (8=Supervisor, 9=Deputy, 10=Leader)
    pMoney,        // Player cash balance
    pLogged,       // Check if logged in
    pFactionWarns  // Faction warning strike tracker
}
new PlayerData[MAX_PLAYERS][pInfo];

// Organization Warehouse Data Structure
enum fWarehouse {
    fMaterials,   // Raw crafting iron/wood materials
    fWeapons,     // Stockpiled ammunition crates
    fMoneyVault   // Stashed black-budget organization cash fund
}
new FactionWarehouse[TOTAL_FACTIONS][fWarehouse];

// Warehouse State Control (0 = Unlocked/Open, 1 = Locked/Closed)
new WarehouseLocked[TOTAL_FACTIONS];

// =============================================================================
//                           SERVER INITIALIZATION
// =============================================================================

main() {
    print("-----------------------------------------------------------------");
    print("           Dimond Play Rp - Absolute Master Core Loaded          ");
    print("-----------------------------------------------------------------");
}

public OnGameModeInit() {
    SetGameModeText("Dimond Play Rp v7.5 Master");
    
    // Seed initial warehouse balances and default all storage units to Open (0)
    for(new i = 1; i < TOTAL_FACTIONS; i++) {
        FactionWarehouse[i][fMaterials] = 5000;  
        FactionWarehouse[i][fWeapons] = 250;     
        FactionWarehouse[i][fMoneyVault] = 50000; 
        WarehouseLocked[i] = 0; // Default state: Open/Unlocked
    }
    return 1;
}

public OnPlayerConnect(playerid) {
    // Reset individual data metrics upon network bridge discovery
    PlayerData[playerid][pAdminLevel] = 0; 
    PlayerData[playerid][pFaction] = FACTION_CITIZEN;
    PlayerData[playerid][pFactionRank] = 1; 
    PlayerData[playerid][pMoney] = 5000;
    PlayerData[playerid][pLogged] = 1;
    PlayerData[playerid][pFactionWarns] = 0;
    
    SendClientMessage(playerid, 0xFFFFFFFF, "Welcome to Dimond Play Rp! Use /help to see job commands.");
    return 1;
}

// =============================================================================
//                           HELPER TRANSLATION SUBROUTINES
// =============================================================================

// Helper Function to convert Admin Level numbers into Custom Names
stock GetAdminRankName(level, dest[], size) {
    if(level == 0) format(dest, size, "Citizen");
    else if(level >= 1 && level <= 5) format(dest, size, "Helper / Trainee");
    else if(level >= 6 && level <= 10) format(dest, size, "Junior Administrator");
    else if(level >= 11 && level <= 19) format(dest, size, "Senior Administrator");
    else if(level >= 20 && level <= 25) format(dest, size, "Chief Administrator");
    else if(level >= 26 && level <= 29) format(dest, size, "Deputy Project Manager");
    else if(level >= 30) format(dest, size, "Founder / Owner");
    return 1;
}

// Helper Function to convert Faction Ranks into Custom Titles
stock GetFactionRankName(rank, dest[], size) {
    if(rank == 8) format(dest, size, "Supervisor");
    else if(rank == 9) format(dest, size, "Deputy Leader");
    else if(rank == 10) format(dest, size, "Leader / Director");
    else format(dest, size, "Employee (Rank %d)", rank);
    return 1;
}

// =============================================================================
//                           COMMAND RECOGNITION INTERCEPTOR
// =============================================================================

public OnPlayerCommandText(playerid, cmdtext[]) {
    
    // ==========================================
    // GLOBAL & CITIZEN COMMANDS
    // ==========================================
    if (strcmp(cmdtext, "/help", true) == 0) {
        SendClientMessage(playerid, 0x33CCFFAA, "--- Dimond Play Rp Master Commands ---");
        SendClientMessage(playerid, 0xFFFFFFFF, "All Org Members: /warehouse | High Rank Actions: /wakedeposit /wakewithdraw");
        SendClientMessage(playerid, 0xFFFFFFFF, "Supervisor (Rank 8+): /warn /unwarn /promote /demote");
        SendClientMessage(playerid, 0xFFFFFFFF, "High Management (Rank 9+): /invite /kickfaction /whlock");
        
        if(PlayerData[playerid][pAdminLevel] >= 30) {
            SendClientMessage(playerid, 0x00FF00FF, "Founder Powers: /givemoneyto /appointleader /removeleader /setadmin");
        }
        return 1;
    }
    
    if (strcmp(cmdtext, "/stats", true) == 0) {
        new string[128];
        new adminName[32];
        new factionRankName[32];
        
        GetAdminRankName(PlayerData[playerid][pAdminLevel], adminName, sizeof(adminName));
        GetFactionRankName(PlayerData[playerid][pFactionRank], factionRankName, sizeof(factionRankName));
        
        format(string, sizeof(string), "[STATS] Faction: %d | Title: %s | Admin: %s (Lvl %d) | Cash: $%d", 
            PlayerData[playerid][pFaction], factionRankName, adminName, PlayerData[playerid][pAdminLevel], PlayerData[playerid][pMoney]);
        SendClientMessage(playerid, 0x33CCFFAA, string);
        return 1;
    }

    // ==========================================
    // ABSOLUTE FOUNDER / OWNER COMMAND OVERRIDES (Level 30 Only)
    // ==========================================
    if (strcmp(cmdtext, "/givemoneyto", true) == 0) {
        if(PlayerData[playerid][pAdminLevel] < 30) return SendClientMessage(playerid, 0xFF0000FF, "Error: Supreme command reserved for Founder Level 30.");
        
        // Simulating financial injection onto targeted profile index records
        SendClientMessage(playerid, 0x00FF00FF, "[FOUNDER POWER] You have injected $500,000 cash directly into the player's account.");
        return 1;
    }

    if (strcmp(cmdtext, "/appointleader", true) == 0) {
        if(PlayerData[playerid][pAdminLevel] < 30) return SendClientMessage(playerid, 0xFF0000FF, "Error: Supreme command reserved for Founder Level 30.");
        
        // Simulating immediate faction override assignment routine
        SendClientMessage(playerid, 0x00FF00FF, "[FOUNDER POWER] You have appointed the target player as Leader (Rank 10) of the Organization.");
        return 1;
    }

    if (strcmp(cmdtext, "/removeleader", true) == 0) {
        if(PlayerData[playerid][pAdminLevel] < 30) return SendClientMessage(playerid, 0xFF0000FF, "Error: Supreme command reserved for Founder Level 30.");
        
        // Resets targeted player configuration fields back to non-affiliated values
        SendClientMessage(playerid, 0xFF0000FF, "[FOUNDER POWER] Leader stripped of duties and demoted back to standard Citizen status.");
        return 1;
    }

    if (strcmp(cmdtext, "/setadmin", true) == 0) {
        if(PlayerData[playerid][pAdminLevel] < 30) return SendClientMessage(playerid, 0xFF0000FF, "Error: Only the Founder (Level 30) can promote other admins.");
        SendClientMessage(playerid, 0x00FF00FF, "Founder Notice: Target user promoted to an Administrative rank.");
        return 1;
    }

    // ==========================================
    // SECURE WAREHOUSE MANAGEMENT SYSTEM
    // ==========================================
    
    // VIEW ACCESS: Everyone inside the organization can see the status balances
    if (strcmp(cmdtext, "/warehouse", true) == 0) {
        new currentFaction = PlayerData[playerid][pFaction];
        if(currentFaction == FACTION_CITIZEN) return SendClientMessage(playerid, 0xFF0000FF, "Error: You do not belong to an organization.");
        
        new string[128];
        new stateString[16];
        if(WarehouseLocked[currentFaction] == 1) format(stateString, sizeof(stateString), "LOCKED/CLOSED");
        else format(stateString, sizeof(stateString), "UNLOCKED/OPEN");

        format(string, sizeof(string), "[WAREHOUSE STATUS: %s] Materials: %d units | Weapon Crates: %d | Vault Fund: $%d", 
            stateString, FactionWarehouse[currentFaction][fMaterials], FactionWarehouse[currentFaction][fWeapons], FactionWarehouse[currentFaction][fMoneyVault]);
        SendClientMessage(playerid, 0x00FF00FF, string);
        return 1;
    }

    // LOCK CONTROL ACCESS: Exclusive to Deputy (Rank 9), Leader (Rank 10), or Founder Lvl 30
    if (strcmp(cmdtext, "/whlock", true) == 0) {
        new currentFaction = PlayerData[playerid][pFaction];
        if(currentFaction == FACTION_CITIZEN) return SendClientMessage(playerid, 0xFF0000FF, "Error: You do not belong to an organization.");
        
        if(PlayerData[playerid][pFactionRank] < 9 && PlayerData[playerid][pAdminLevel] < 30) {
            return SendClientMessage(playerid, 0xFF0000FF, "Error: Access Denied. Only your Deputy (Rank 9) or Leader (Rank 10) can lock/unlock.");
        }
        
        if(WarehouseLocked[currentFaction] == 0) {
            WarehouseLocked[currentFaction] = 1;
            SendClientMessage(playerid, 0xFF0000FF, "Warehouse System: Storage vault status changed to LOCKED / CLOSED.");
        } else {
            WarehouseLocked[currentFaction] = 0;
            SendClientMessage(playerid, 0x00FF00FF, "Warehouse System: Storage vault status changed to UNLOCKED / OPEN.");
        }
        return 1;
    }

    // ASSET EXTRACTION INTERCEPT: Respects the active warehouse lock status state
    if (strcmp(cmdtext, "/wakewithdraw", true) == 0) {
    new currentFaction = PlayerData[playerid][pFaction];
    if(currentFaction == FACTION_CITIZEN) return SendClientMessage(playerid, 0xFF0000FF, "Error: You do not belong to an organization.");
        
    // VIEW ACCESS: Everyone inside the organization can see the status balances
    if (strcmp(cmdtext, "/warehouse", true) == 0) {
        new string;
        new stateString;
        if(WarehouseLocked[currentFaction] == 1) format(stateString, sizeof(stateString), "LOCKED/CLOSED");
        else format(stateString, sizeof(stateString), "UNLOCKED/OPEN");

        format(string, sizeof(string), "[WAREHOUSE STATUS: %s] Materials: %d units | Weapon Crates: %d | Vault Fund: $%d", 
            stateString, FactionWarehouse[currentFaction][fMaterials], FactionWarehouse[currentFaction][fWeapons], FactionWarehouse[currentFaction][fMoneyVault]);
        SendClientMessage(playerid, 0x00FF00FF, string);
        return 1;
    }

    // LOCK CONTROL ACCESS: Exclusive to Deputy (Rank 9), Leader (Rank 10), or Founder Lvl 30
    if (strcmp(cmdtext, "/whlock", true) == 0) {
        if(PlayerData[playerid][pFactionRank] < 9 && PlayerData[playerid][pAdminLevel] < 30) {
            return SendClientMessage(playerid, 0xFF0000FF, "Error: Access Denied. Only your Deputy (Rank 9) or Leader (Rank 10) can lock/unlock.");
        }
        
        if(WarehouseLocked[currentFaction] == 0) {
            WarehouseLocked[currentFaction] = 1;
            SendClientMessage(playerid, 0xFF0000FF, "Warehouse System: Storage vault status changed to LOCKED / CLOSED.");
        } else {
            WarehouseLocked[currentFaction] = 0;
            SendClientMessage(playerid, 0x00FF00FF, "Warehouse System: Storage vault status changed to UNLOCKED / OPEN.");
        }
        return 1;
    }

    // ASSET EXTRACTION INTERCEPT: Respects the active warehouse lock status state
    if (strcmp(cmdtext, "/wakewithdraw", true) == 0) {
        // If locked, block anyone under Rank 9 (including Rank 8 Supervisors)
        if(WarehouseLocked[currentFaction] == 1 && PlayerData[playerid][pFactionRank] < 9 && PlayerData[playerid][pAdminLevel] < 30) {
            return SendClientMessage(playerid, 0xFF0000FF, "Error: The warehouse is closed. Only your Deputy and Leader can bypass security.");
        }
        
        SendClientMessage(playerid, 0x00FF00FF, "Warehouse Action: Item removed successfully.");
        return 1;
    }

    if (strcmp(cmdtext, "/wakedeposit", true) == 0) {
        if(WarehouseLocked[currentFaction] == 1 && PlayerData[playerid][pFactionRank] < 9 && PlayerData[playerid][pAdminLevel] < 30) {
            return SendClientMessage(playerid, 0xFF0000FF, "Error: Warehouse is closed. You cannot load items inside.");
        }
        
        SendClientMessage(playerid, 0x00FF00FF, "Warehouse Action: Assets successfully loaded into your secure vaults.");
        return 1;
    }

    // ==========================================
    // FACTION MANAGEMENT UTILITIES (Rank 9, 10, Owner Only - Rank 8 blocked)
    // ==========================================
    if (strcmp(cmdtext, "/invite", true) == 0) {
        if(PlayerData[playerid][pFactionRank] < 9 && PlayerData[playerid][pAdminLevel] < 30) {
            return SendClientMessage(playerid, 0xFF0000FF, "Error: Rank 8 cannot recruit. Requires Deputy (Rank 9) or Leader (Rank 10).");
        }
        SendClientMessage(playerid, 0x00FF00FF, "Management Action: You successfully invited a new citizen into your organization.");
        return 1;
    }

    if (strcmp(cmdtext, "/kickfaction", true) == 0) {
        if(PlayerData[playerid][pFactionRank] < 9 && PlayerData[playerid][pAdminLevel] < 30) {
            return SendClientMessage(playerid, 0xFF0000FF, "Error: Rank 8 cannot kick players. Requires Deputy (Rank 9) or Leader (Rank 10).");
        }
        SendClientMessage(playerid, 0xFF0000FF, "Management Action: Player discharged from the organization.");
        return 1;
    }

    // ==========================================
    // DISCIPLINARY SUPERVISOR ACTIONS (Rank 8, 9, 10, Owner Allowed)
    // ==========================================
    if (strcmp(cmdtext, "/promote", true) == 0) {
        if(PlayerData[playerid][pFactionRank] < 8 && PlayerData[playerid][pAdminLevel] < 30) {
            return SendClientMessage(playerid, 0xFF0000FF, "Error: You must be at least a Supervisor (Rank 8+).");
        }
        SendClientMessage(playerid, 0x00FF00FF, "Org Action: Target employee has been promoted up 1 rank.");
        return 1;
    }

    if (strcmp(cmdtext, "/demote", true) == 0) {
        if(PlayerData[playerid][pFactionRank] < 8 && PlayerData[playerid][pAdminLevel] < 30) {
            return SendClientMessage(playerid, 0xFF0000FF, "Error: You must be at least a Supervisor (Rank 8+).");
        }
        SendClientMessage(playerid, 0xFF0000FF, "Org Action: Target employee has been demoted down 1 rank.");
        return 1;
    }

    if (strcmp(cmdtext, "/warn", true) == 0) {
        if(PlayerData[playerid][pFactionRank] < 8 && PlayerData[playerid][pAdminLevel] < 30) {
            return SendClientMessage(playerid, 0xFF0000FF, "Error: You must be at least a Supervisor (Rank 8+).");
        }
        SendClientMessage(playerid, 0xEAA300FF, "Org Action: Warning issued to employee for policy violation.");
        return 1;
    }

    if (strcmp(cmdtext, "/unwarn", true) == 0) {
        if(PlayerData[playerid][pFactionRank] < 8 && PlayerData[playerid][pAdminLevel] < 30) {
            return SendClientMessage(playerid, 0xFF0000FF, "Error: You must be at least a Supervisor (Rank 8+).");
        }
        SendClientMessage(playerid, 0x00FF00FF, "Org Action: Organization warning strike removed from employee.");
        return 1;
    }

    return 0;
}

