CREATE TABLE IF NOT EXISTS `anox_blackmarket_locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `last_change` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `current_location` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
);

INSERT INTO `anox_blackmarket_locations` (`id`, `last_change`, `current_location`) VALUES
(1, CURRENT_TIMESTAMP, 0);