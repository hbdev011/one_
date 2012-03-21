-- phpMyAdmin SQL Dump
-- version 3.4.5deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jan 24, 2012 at 03:53 PM
-- Server version: 5.1.58
-- PHP Version: 5.3.6-13ubuntu3.3

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `config_development`
--

-- --------------------------------------------------------

--
-- Table structure for table `bediengeraets`
--

DROP TABLE IF EXISTS `bediengeraets`;
CREATE TABLE IF NOT EXISTS `bediengeraets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `nummer` varchar(255) DEFAULT NULL,
  `name8stellig` varchar(255) DEFAULT NULL,
  `name4stellig` varchar(255) DEFAULT NULL,
  `unit` int(11) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `bdtype_id` int(11) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `normalquellen_kv_id` int(11) DEFAULT NULL,
  `splitquellen_kv_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `sende_matrix_id` int(11) DEFAULT NULL,
  `sende_senke_id` int(11) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `upside_down` tinyint(4) NOT NULL DEFAULT '0',
  `vertical` tinyint(4) NOT NULL DEFAULT '0',
  `matching_set` int(11) NOT NULL DEFAULT '0',
  `matching_start_quelle` int(11) NOT NULL DEFAULT '0',
  `matching_end_quelle` int(11) NOT NULL DEFAULT '0',
  `visible_quellen_pages` int(11) NOT NULL DEFAULT '0',
  `visible_shift_pages` int(11) NOT NULL DEFAULT '0',
  `label_quellen` int(11) NOT NULL DEFAULT '0',
  `font_quellen` int(11) NOT NULL DEFAULT '0',
  `label_split` int(11) NOT NULL DEFAULT '0',
  `font_split` int(11) NOT NULL DEFAULT '0',
  `label_senken` int(11) NOT NULL DEFAULT '0',
  `font_senken` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_bediengeraets_on_intnummer` (`intnummer`),
  KEY `index_bediengeraets_on_system_id` (`system_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=13185 ;

-- --------------------------------------------------------

--
-- Table structure for table `bgs`
--

DROP TABLE IF EXISTS `bgs`;
CREATE TABLE IF NOT EXISTS `bgs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `bmes`
--

DROP TABLE IF EXISTS `bmes`;
CREATE TABLE IF NOT EXISTS `bmes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `taste` int(11) DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `peview_monitor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bmes_on_taste` (`taste`),
  KEY `index_bmes_on_system_id` (`system_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=29593 ;

-- --------------------------------------------------------

--
-- Table structure for table `crosspoints`
--

DROP TABLE IF EXISTS `crosspoints`;
CREATE TABLE IF NOT EXISTS `crosspoints` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nummer` int(11) DEFAULT NULL,
  `salvo_id` int(11) DEFAULT NULL,
  `kreuzschiene_id` int(11) DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `target_id` int(11) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `stack` varchar(10) DEFAULT NULL,
  `frame` int(11) DEFAULT NULL,
  `slot` int(11) DEFAULT NULL,
  `parameter` varchar(100) DEFAULT NULL,
  `value` varchar(100) DEFAULT NULL,
  `source_single_class` varchar(100) DEFAULT NULL,
  `source_subclass` varchar(100) DEFAULT NULL,
  `source_component` varchar(100) DEFAULT NULL,
  `source_subcomponent` varchar(100) DEFAULT NULL,
  `delay` int(4) NOT NULL DEFAULT '0',
  `dest_single_class` varchar(100) DEFAULT NULL,
  `dest_subclass` varchar(100) DEFAULT NULL,
  `dest_component` varchar(100) DEFAULT NULL,
  `dest_subcomponent` varchar(100) DEFAULT NULL,
  `comment` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_crosspoints_on_nummer` (`nummer`),
  KEY `index_crosspoints_on_system_id` (`system_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=641 ;

-- --------------------------------------------------------

--
-- Table structure for table `devices`
--

DROP TABLE IF EXISTS `devices`;
CREATE TABLE IF NOT EXISTS `devices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `nummer` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `protocol_id` int(11) DEFAULT NULL,
  `unit` int(11) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4389 ;

-- --------------------------------------------------------

--
-- Table structure for table `families`
--

DROP TABLE IF EXISTS `families`;
CREATE TABLE IF NOT EXISTS `families` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nummer` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `system_color_id` int(11) DEFAULT NULL,
  `position` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=102 ;

-- --------------------------------------------------------

--
-- Table structure for table `family_panels`
--

DROP TABLE IF EXISTS `family_panels`;
CREATE TABLE IF NOT EXISTS `family_panels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `system_id` int(11) NOT NULL,
  `matrix` int(11) NOT NULL,
  `quellen` int(11) NOT NULL,
  `family` int(11) NOT NULL,
  `source_type` enum('source','target') NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=17235 ;

-- --------------------------------------------------------

--
-- Table structure for table `frames`
--

DROP TABLE IF EXISTS `frames`;
CREATE TABLE IF NOT EXISTS `frames` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `funktion` varchar(255) DEFAULT NULL,
  `ipadresse` varchar(255) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_frames_on_intnummer` (`intnummer`),
  KEY `index_frames_on_system_id` (`system_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3700 ;

-- --------------------------------------------------------

--
-- Table structure for table `gp_inputs`
--

DROP TABLE IF EXISTS `gp_inputs`;
CREATE TABLE IF NOT EXISTS `gp_inputs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `value` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `unit` int(11) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `byte` int(11) DEFAULT NULL,
  `bit` int(11) DEFAULT NULL,
  `invert` int(2) DEFAULT NULL,
  `radio` int(2) DEFAULT NULL,
  `comment` varchar(16) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `i_type` int(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=897 ;

-- --------------------------------------------------------

--
-- Table structure for table `gp_in_signals`
--

DROP TABLE IF EXISTS `gp_in_signals`;
CREATE TABLE IF NOT EXISTS `gp_in_signals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `value` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=316 ;

-- --------------------------------------------------------

--
-- Table structure for table `gp_nodes`
--

DROP TABLE IF EXISTS `gp_nodes`;
CREATE TABLE IF NOT EXISTS `gp_nodes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `value` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=20 ;

-- --------------------------------------------------------

--
-- Table structure for table `gp_outputs`
--

DROP TABLE IF EXISTS `gp_outputs`;
CREATE TABLE IF NOT EXISTS `gp_outputs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `value` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `active_name` varchar(255) DEFAULT NULL,
  `inactive_name` varchar(255) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `unit` int(11) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `byte` int(11) DEFAULT NULL,
  `bit` int(11) DEFAULT NULL,
  `invert` int(2) DEFAULT NULL,
  `comment` varchar(16) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `mode` int(1) DEFAULT NULL,
  `o_type` int(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=897 ;

-- --------------------------------------------------------

--
-- Table structure for table `gp_out_signals`
--

DROP TABLE IF EXISTS `gp_out_signals`;
CREATE TABLE IF NOT EXISTS `gp_out_signals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `value` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=131 ;

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
CREATE TABLE IF NOT EXISTS `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `in_out_tables`
--

DROP TABLE IF EXISTS `in_out_tables`;
CREATE TABLE IF NOT EXISTS `in_out_tables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `input1` int(11) DEFAULT NULL,
  `input2` int(11) DEFAULT NULL,
  `input3` int(11) DEFAULT NULL,
  `input4` int(11) DEFAULT NULL,
  `input5` int(11) DEFAULT NULL,
  `input6` int(11) DEFAULT NULL,
  `input7` int(11) DEFAULT NULL,
  `input8` int(11) DEFAULT NULL,
  `output` int(11) DEFAULT NULL,
  `function` text,
  `action_term` text,
  `action_term_output` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `boolean_expr` text,
  `tt_val` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=16 ;

-- --------------------------------------------------------

--
-- Table structure for table `kreuzschienes`
--

DROP TABLE IF EXISTS `kreuzschienes`;
CREATE TABLE IF NOT EXISTS `kreuzschienes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `nummer` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `protocol_id` int(11) DEFAULT NULL,
  `input` int(11) DEFAULT NULL,
  `output` int(11) DEFAULT NULL,
  `unit` int(11) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `unit2` int(11) DEFAULT NULL,
  `port2` int(11) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `ip2` varchar(255) DEFAULT NULL,
  `kr_type` varchar(255) DEFAULT NULL,
  `mixer_template_id` int(11) DEFAULT NULL,
  `ref_matrix_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_kreuzschienes_on_intnummer` (`intnummer`),
  KEY `index_kreuzschienes_on_system_id` (`system_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5226 ;

-- --------------------------------------------------------

--
-- Table structure for table `mixer_tallies`
--

DROP TABLE IF EXISTS `mixer_tallies`;
CREATE TABLE IF NOT EXISTS `mixer_tallies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `nummer` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `kreuzschiene_id` int(11) DEFAULT NULL,
  `senke_id` int(11) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=309 ;

-- --------------------------------------------------------

--
-- Table structure for table `mixer_templates`
--

DROP TABLE IF EXISTS `mixer_templates`;
CREATE TABLE IF NOT EXISTS `mixer_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `input` int(11) DEFAULT NULL,
  `output` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=105 ;

-- --------------------------------------------------------

--
-- Table structure for table `mixer_template_setups`
--

DROP TABLE IF EXISTS `mixer_template_setups`;
CREATE TABLE IF NOT EXISTS `mixer_template_setups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `mixer_template_id` int(11) DEFAULT NULL,
  `name5stellig` varchar(255) DEFAULT NULL,
  `name4stellig` varchar(255) DEFAULT NULL,
  `char6` varchar(255) DEFAULT NULL,
  `char10` varchar(255) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `tallybit` int(11) DEFAULT NULL,
  `system_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=942 ;

-- --------------------------------------------------------

--
-- Table structure for table `salvos`
--

DROP TABLE IF EXISTS `salvos`;
CREATE TABLE IF NOT EXISTS `salvos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `salvo_type` int(5) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=6 ;

-- --------------------------------------------------------

--
-- Table structure for table `schema_info`
--

DROP TABLE IF EXISTS `schema_info`;
CREATE TABLE IF NOT EXISTS `schema_info` (
  `version` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `sources`
--

DROP TABLE IF EXISTS `sources`;
CREATE TABLE IF NOT EXISTS `sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `nummer` int(11) DEFAULT NULL,
  `name5stellig` varchar(255) DEFAULT NULL,
  `name4stellig` varchar(255) DEFAULT NULL,
  `kreuzschiene_id` int(11) DEFAULT NULL,
  `bediengeraet_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `char6` varchar(255) DEFAULT NULL,
  `char10` varchar(255) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `cloneinput` varchar(255) DEFAULT NULL,
  `matrix` varchar(255) DEFAULT NULL,
  `quelle` varchar(255) DEFAULT NULL,
  `tallybit` int(11) DEFAULT '0',
  `mx_matrix` int(11) DEFAULT NULL,
  `mx_senke` int(11) DEFAULT NULL,
  `signal` int(11) DEFAULT NULL,
  `subclass` int(11) DEFAULT NULL,
  `component` int(11) DEFAULT NULL,
  `subcomponent` int(11) DEFAULT NULL,
  `channel` int(11) NOT NULL DEFAULT '1',
  `real_input` int(11) DEFAULT NULL,
  `family_id` int(11) DEFAULT '0',
  `enable` int(1) NOT NULL DEFAULT '0',
  `par_matrix` int(11) DEFAULT NULL,
  `par_quelle` int(11) DEFAULT NULL,
  `green` int(11) NOT NULL DEFAULT '0',
  `yellow` int(11) NOT NULL DEFAULT '0',
  `blue` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_sources_on_kreuzschiene_id` (`kreuzschiene_id`),
  KEY `index_sources_on_intnummer` (`intnummer`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1418455 ;

-- --------------------------------------------------------

DROP TABLE IF EXISTS `system_assoziations`;
CREATE TABLE IF NOT EXISTS `system_assoziations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `system_id` int(11) NOT NULL,
  `intnummer` int(11) NOT NULL,
  `source_matrix` int(11) DEFAULT NULL,
  `source_senke` int(11) DEFAULT NULL,
  `matrix_1` int(11) DEFAULT NULL,
  `senke_1` int(11) DEFAULT NULL,
  `matrix_2` int(11) DEFAULT NULL,
  `senke_2` int(11) DEFAULT NULL,
  `matrix_3` int(11) DEFAULT NULL,
  `senke_3` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=250 ;

-- --------------------------------------------------------

--
-- Table structure for table `system_colors`
--

DROP TABLE IF EXISTS `system_colors`;
CREATE TABLE IF NOT EXISTS `system_colors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nummer` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `red` varchar(255) DEFAULT NULL,
  `green` varchar(50) NOT NULL,
  `blue` varchar(50) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=61 ;

-- --------------------------------------------------------

--
-- Table structure for table `system_matchings`
--

DROP TABLE IF EXISTS `system_matchings`;
CREATE TABLE IF NOT EXISTS `system_matchings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `system_id` int(11) NOT NULL,
  `intnummer` int(11) NOT NULL,
  `matching_set` int(11) NOT NULL DEFAULT '0',
  `matching_panel` int(11) DEFAULT NULL,
  `matching_start_quelle` int(11) DEFAULT NULL,
  `matching_end_quelle` int(11) DEFAULT NULL,
  `matching_matrix` int(11) DEFAULT NULL,
  `matching_senke` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=142 ;

-- --------------------------------------------------------

--
-- Table structure for table `tallies`
--

DROP TABLE IF EXISTS `tallies`;
CREATE TABLE IF NOT EXISTS `tallies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `nummer` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `kreuzschiene_id` int(11) DEFAULT NULL,
  `senke_id` int(11) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1684 ;

-- --------------------------------------------------------

--
-- Table structure for table `targets`
--

DROP TABLE IF EXISTS `targets`;
CREATE TABLE IF NOT EXISTS `targets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `nummer` int(11) DEFAULT NULL,
  `name5stellig` varchar(255) DEFAULT NULL,
  `name4stellig` varchar(255) DEFAULT NULL,
  `kreuzschiene_id` int(11) DEFAULT NULL,
  `bediengeraet_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `char6` varchar(255) DEFAULT NULL,
  `char10` varchar(255) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `matrix` varchar(255) DEFAULT NULL,
  `quelle` varchar(255) DEFAULT NULL,
  `cloneinput` varchar(255) DEFAULT NULL,
  `tallybit` varchar(255) DEFAULT NULL,
  `mx_tallybit` int(11) DEFAULT NULL,
  `mx_matrix` int(11) DEFAULT NULL,
  `mx_quelle` int(11) DEFAULT NULL,
  `signal` int(11) DEFAULT NULL,
  `subclass` int(11) DEFAULT NULL,
  `component` int(11) DEFAULT NULL,
  `subcomponent` int(11) DEFAULT NULL,
  `channel` int(11) NOT NULL DEFAULT '1',
  `real_output` int(11) DEFAULT NULL,
  `family_id` int(11) DEFAULT '0',
  `red` tinyint(4) NOT NULL DEFAULT '0',
  `green` tinyint(4) NOT NULL DEFAULT '0',
  `yellow` tinyint(4) NOT NULL DEFAULT '0',
  `blue` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_targets_on_kreuzschiene_id` (`kreuzschiene_id`),
  KEY `index_targets_on_intnummer` (`intnummer`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1397661 ;

-- --------------------------------------------------------

--
-- Table structure for table `typ1s`
--

DROP TABLE IF EXISTS `typ1s`;
CREATE TABLE IF NOT EXISTS `typ1s` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nummer` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `kv` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `typ2s`
--

DROP TABLE IF EXISTS `typ2s`;
CREATE TABLE IF NOT EXISTS `typ2s` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nummer` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `kv` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `typ3s`
--

DROP TABLE IF EXISTS `typ3s`;
CREATE TABLE IF NOT EXISTS `typ3s` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nummer` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `kv` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `typ4s`
--

DROP TABLE IF EXISTS `typ4s`;
CREATE TABLE IF NOT EXISTS `typ4s` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nummer` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `kv` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `typesources`
--

DROP TABLE IF EXISTS `typesources`;
CREATE TABLE IF NOT EXISTS `typesources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bediengeraet_id` int(11) DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `tasten_id` int(11) DEFAULT NULL,
  `sourcetype` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `matrix` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_typesources_on_bediengeraet_id` (`bediengeraet_id`),
  KEY `index_typesources_on_tasten_id` (`tasten_id`),
  KEY `index_typesources_on_sourcetype` (`sourcetype`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1802155 ;

-- --------------------------------------------------------

--
-- Table structure for table `typetargets`
--

DROP TABLE IF EXISTS `typetargets`;
CREATE TABLE IF NOT EXISTS `typetargets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bediengeraet_id` int(11) DEFAULT NULL,
  `target_id` int(11) DEFAULT NULL,
  `tasten_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `matrix` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_typetargets_on_bediengeraet_id` (`bediengeraet_id`),
  KEY `index_typetargets_on_tasten_id` (`tasten_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=145454 ;

-- --------------------------------------------------------

--
-- Table structure for table `umds`
--

DROP TABLE IF EXISTS `umds`;
CREATE TABLE IF NOT EXISTS `umds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `intnummer` int(11) DEFAULT NULL,
  `umdnummer` varchar(255) DEFAULT NULL,
  `kreuzschiene_id` int(11) DEFAULT NULL,
  `target_id` int(11) DEFAULT NULL,
  `festtext` varchar(255) DEFAULT NULL,
  `monitor` varchar(255) DEFAULT NULL,
  `gpi` varchar(255) DEFAULT NULL,
  `bme` varchar(255) DEFAULT NULL,
  `mon_havarie` varchar(255) DEFAULT NULL,
  `konfiguration` varchar(255) DEFAULT NULL,
  `system_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `pgm_monitor` varchar(255) DEFAULT NULL,
  `choice` enum('0','1') NOT NULL DEFAULT '0',
  `type_option` enum('0','1') NOT NULL DEFAULT '0',
  `ip_address` varchar(255) DEFAULT NULL,
  `panel` int(11) NOT NULL DEFAULT '0',
  `vts_input` int(11) NOT NULL DEFAULT '0',
  `source_id` int(11) DEFAULT NULL,
  `master_umd` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_umds_on_intnummer` (`intnummer`),
  KEY `index_umds_on_system_id` (`system_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=26305 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
