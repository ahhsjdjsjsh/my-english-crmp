CREATE TABLE IF NOT EXISTS `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(24) NOT NULL,
  `password` varchar(64) NOT NULL,
  `level` int(11) NOT NULL DEFAULT '1',
  `money` int(11) NOT NULL DEFAULT '5000',
  `admin_level` int(11) NOT NULL DEFAULT '0',
  `faction` int(11) NOT NULL DEFAULT '0',
  `faction_rank` int(11) NOT NULL DEFAULT '1',
  `faction_warns` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `players` (`username`, `password`, `admin_level`, `money`, `faction`, `faction_rank`) 
VALUES ('charchitjain', 'bossayush', 30, 500000, 0, 1);

INSERT INTO `players` (`username`, `password`, `admin_level`, `money`, `faction`, `faction_rank`) 
VALUES ('HirenproGaming', 'hirenboi', 30, 500000, 0, 1);
