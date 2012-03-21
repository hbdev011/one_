class Global

  # Typen-Definition
  TYP1_NORMALQUELLEN = 32.freeze
  TYP1_SPLITQUELLEN = 0.freeze
  TYP1_SENKEN = 1.freeze

  TYP2_NORMALQUELLEN = 256.freeze
  TYP2_SPLITQUELLEN = 16.freeze
  TYP2_SENKEN = 1.freeze

  TYP3_NORMALQUELLEN = 256.freeze	# war 256
  TYP3_SPLITQUELLEN = 16.freeze
  TYP3_SENKEN = 30.freeze					# war 32 nur zum Test

  TYP4_NORMALQUELLEN = 10.freeze
  TYP4_SPLITQUELLEN = 0.freeze
  TYP4_SENKEN = 1.freeze

  TYP6_NORMALQUELLEN = 85.freeze

  TYP5_NORMALQUELLEN = 256.freeze
  TYP5_SPLITQUELLEN = 16.freeze
  TYP5_SENKEN = 75.freeze
  TYP5_SENKEN_ROWS = 5.freeze

  # FTP-Konfiguration
  FTPDIR = "hd".freeze
  FTPUSER = "root".freeze
  FTPPASSWD ="".freeze
  PANEL_FTPPASSWD ="ibt-ftp-01".freeze
  PANEL_FTPDIR = "tmp".freeze

  CON_TIMEOUT = 2.freeze        # Zeit in s die auf eine Verbindung gewartet wird
  TRANSFER_TIMEOUT = 30.freeze  # Zeit in s erlaubt für die Übertragung
  CLOSE_TIMEOUT = 1.freeze      # Zeit in s nach dem close-Befehl zum sauberen Schliessen des Kanals

  # Initiale Input/Output für KBs
  IOINITIAL = 512.freeze
  IOINITIAL_STAGETEK = 1000.freeze
  MAXTALLYBIT = 32
  MAXDEVICE = 10

  MAX_UNIT = 9
  MAX_PORT = 12
  MAX_PANEL = 32
  MAX_BYTE = 2

  PORT_RESTRICTION = {"Top Ports" => 1, "Bottom Ports" => 2, "No" => 3}
  MULTIVIEWER = {"5 Char" => 1, "6 Char" => 2, "10 Char" => 3, "16 Char" => 4}

  MAXTALLY = ["RED_TALLY", "GREEN_TALLY", "ORANGE_TALLY", "BLUE_TALLY"]
  READBACKTALLY = ["KV_HAV_TALLY", "GREEN_TALLY", "ORANGE_TALLY", "BLUE_TALLY"]

  VERSION = "003"
  SYSTEM_VERSION = "2.1.04.04"

  MAXSIMULATEDDESTINATION = 256
  VTS_MAX_IMPUTS = 16

  SHIFT_TYPE_6 = 17
  FAMILY_TYPE_6 = 16
  AUDIS_TYPE_6 = 15

  SHIFT_TYPE_5 = 50
  FAMILY_TYPE_5 = 49
  AUDIS_TYPE_5 = 48

  BUTTON_PER_ROW_PANEL6 = 17	
  AUDIS_FAMILY_SHIFT_ARRAY_PANEL6 = [15,16,17,32,33,34,49,50,51,66,67,68,83,84,85]
  FAMILY_SHIFT_ARRAY_PANEL6 = [16,17,33,34,50,51,67,68,79,80]
  AUDIS_ARRAY_PANEL6 = [15,32,49,66,83]
  SHIFT_ARRAY_PANEL6 = [17,34,51,68,85]	
  			
  AUDIS_FAMILY_SHIFT_ARRAY_PANEL5 = [14,15,16,30,31,32,46,47,48,62,63,64,78,79,80]
  FAMILY_SHIFT_ARRAY_PANEL5 = [15,16,31,32,47,48,63,64,79,80]
  AUDIS_ARRAY_PANEL5 = [14,30,46,62,78]
  SHIFT_ARRAY_PANEL5 = [16,32,48,64,80]	
  
  QUELLEN_FONT = {"1 Line 4 Char." => "1", "1 Line 5 Char." => "3", "2 Line 5 Char." => "4", "1 Line 8 Char." => "5", "1 Line 10 Char." => "7"}.sort_by { |k,v| v }
  SENKEN_FONT = {"2 Line 4 Char." => "2", "2 Line 5 Char." => "4","2 Line 8 Char." => "6", "2 Line 10 Char." => "8"}.sort_by { |k,v| v }
end
