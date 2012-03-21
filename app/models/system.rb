class System < ActiveRecord::Base
	require 'fileutils'
  has_many :frames
  has_many :kreuzschienes , :order=>"intnummer"
  has_many :devices , :order=>"intnummer"
  has_many :bediengeraets
  has_many :umds
  has_many :crosspoints
  has_many :tallies
  has_many :mixer_tallies
  has_many :mixer_templates

  def formatstring(str, len)
	begin
	  returner = ('"' + str.ljust(len) + '"').to_s
	rescue
	  returner = ('"' + "".ljust(len) + '"').to_s
	end
  end

  def formatnumber2(nbr)
	return "0" + nbr.to_i.to_s if nbr.to_i<10
	return "00" if nbr.nil? or nbr==0
	return nbr.to_s
  end

  # => To Get Salvo type
  def get_salvo_type(nbr)
      return sprintf("%02d",Salvo.find_by_intnummer(nbr,:select => "salvo_type").salvo_type)
  end
  ###
  def formatnumber3(nbr)
	return "000" if nbr.nil? || nbr.blank?
	return "00" + nbr.to_s if nbr.to_i<10
	return "0" + nbr.to_s if nbr.to_i<100
	return nbr.to_s
  end

  def formatnumber4(nbr)
	return "0000" if nbr.nil? || nbr.blank?
	return "000" + nbr.to_s if nbr.to_i<10
	return "00" + nbr.to_s if nbr.to_i<100
	return "0" + nbr.to_s if nbr.to_i<1000
	return nbr.to_s
  end

  def createBDTypDummy(id, typnr)
	System.transaction do
	  if typnr==1 then
		c=0
		Global::TYP1_NORMALQUELLEN.times  {
		  c=c+1
		  Typesource.new(:tasten_id=>c, :bediengeraet_id=>id, :source_id=>0, :sourcetype=>'normal').save
		}
		# Senke anlegen
		Typetarget.new(:tasten_id=>1, :bediengeraet_id=>id, :target_id=>0).save

	  elsif typnr==2 then
		# Quellen anlegen
		c=0
		Global::TYP2_NORMALQUELLEN.times  {
		  c=c+1
		  Typesource.new(:tasten_id => c, :bediengeraet_id => id, :source_id => 0, :sourcetype  => 'normal').save
		}

		# Quellen anlegen
		c=0
		Global::TYP2_SPLITQUELLEN.times  {
		  c=c+1
		  Typesource.new(:tasten_id=>c, :bediengeraet_id=>id, :source_id=>0, :sourcetype=>'split').save
		}

		# Senke anlegen
		Typetarget.new(:tasten_id=>1, :bediengeraet_id=>id, :target_id=>0).save

	  elsif typnr==3 then
		# Quellen anlegen
		c=0
		Global::TYP3_NORMALQUELLEN.times  {
			c=c+1
			Typesource.new(:tasten_id=>c, :bediengeraet_id=>id, :source_id=>0, :sourcetype => 'normal').save
		}

		# Quellen anlegen
		c=0
		Global::TYP3_NORMALQUELLEN.times  {
			c=c+1
			Typesource.new(:tasten_id => c, :bediengeraet_id=>id, :source_id=>0, :sourcetype => 'split').save
		}

		# Senke anlegen
		c=0
		Global::TYP3_SENKEN.times  {
		  c=c+1
		  if [16, 32].include? c
			c=c+1
		  end
		  Typetarget.new(:tasten_id=>c, :bediengeraet_id=>id, :target_id=>0).save
		}

      elsif typnr==4 then
        # Quellen anlegen
        c=0
        Global::TYP4_NORMALQUELLEN.times  {
          c=c+1
          Typesource.new(:tasten_id=>c, :bediengeraet_id=>id, :source_id=>0, :sourcetype => 'normal').save
        }

        # Senke anlegen
        Typetarget.new(:tasten_id=>1, :bediengeraet_id=>id, :target_id=>0).save

      elsif typnr==5 then
        # Quellen anlegen
        c=0
        Global::TYP5_NORMALQUELLEN.times  {
          c=c+1
          Typesource.new(:tasten_id=>c, :bediengeraet_id=>id, :source_id=>0, :sourcetype => 'normal').save
        }

        # Quellen anlegen
        c=0
        Global::TYP5_NORMALQUELLEN.times  {
          c=c+1
          Typesource.new(:tasten_id=>c, :bediengeraet_id=>id, :source_id=>0, :sourcetype=>'split').save
        }

        # Senke anlegen
        c=0
        Global::TYP5_SENKEN.times  {
          c=c+1
          if [16, 32, 48, 64, 80].include? c
            c=c+1
          end
          Typetarget.new(:tasten_id=>c, :bediengeraet_id=>id, :target_id=>0).save
        }
      elsif typnr==6 then
        # Quellen anlegen
	c=0
	Global::TYP6_NORMALQUELLEN.times  {
	  c=c+1
	  if [16, 32, 48, 64, 80].include? c
	    c=c+1
	  end
	  Typesource.new(:tasten_id=>c, :bediengeraet_id=>id, :source_id=>0, :sourcetype=>'normal').save
	}
	Typetarget.new(:tasten_id=>1, :bediengeraet_id=>id, :target_id=>1).save
      end

    end #transaction

  end


  def build_clean_configuration(start_ip)
      system_id = self.id

      System.transaction do

		########################################
		### FRAMES                  SYSTEM-AWARE

		Frame.destroy_all(:system_id=>system_id)

		# Vorformatierung der Tabellen
		c=1
		Frame.new(:intnummer=>c, :name=>'UNIT ' + c.to_s , :funktion=>'MASTER', :ipadresse=>start_ip, :system_id=>system_id).save
		(Global::MAX_UNIT-1).times  {
		  c=c+1
		  Frame.new(:intnummer=>c, :name=>'UNIT ' + c.to_s , :funktion=>'SLAVE', :ipadresse=>'', :system_id=>system_id).save
		}

		######################################
		### Bediengeraete         SYSTEM-AWARE

		Bediengeraet.destroy_all(:system_id=>system_id)

		c=0
		32.times  {
		  c=c+1
		  Bediengeraet.new(:intnummer=>c, :nummer=>'BD_' + formatnumber2(c), :system_id=>system_id, :bdtype_id=>0).save
		}

		######################################
		### Kreuzschienen         SYSTEM-AWARE
		######################################

		Kreuzschiene.destroy_all(:system_id=>system_id)

		c=0
		9.times  {
		  logger.info "creating KV"
		  Kreuzschiene.new(:intnummer=>c, :nummer=>'KV_0' + c.to_s, :name=>'', :kr_type => "", :mixer_template_id => nil, :protocol_id=>nil, :input=>nil, :output=>nil, :unit=>nil, :port=>nil, :system_id=>system_id).save
		  c=c+1
		}

		######################################
		#### Devices         SYSTEM-AWARE ####
		######################################

		Device.destroy_all(:system_id=>system_id)

		c=0
		Global::MAXDEVICE.times  {
		  c=c+1
		  logger.info "creating SO"
		  c < 10 ? str = "DEV_0" : str = "DEV_"
		  Device.new(:intnummer => c, :nummer => str + c.to_s, :name => nil, :protocol_id => nil, :unit => nil, :port => nil, :ip => nil, :system_id => system_id).save
		}

        ######################################
        ### Tally         SYSTEM-AWARE

        Tally.destroy_all(:system_id=>system_id)

        c=0
        Global::MAXTALLY.size.times  {
          c=c+1
          logger.info "creating Tally"
          Tally.new(:intnummer=>c, :nummer=> c.to_s, :name=>Global::MAXTALLY[c-1].to_s, :kreuzschiene_id=>nil, :senke_id=>nil, :system_id=>system_id).save
        }

        ######################################
        ### SALVO SECTION     SYSTEM-AWARE

        Salvo.destroy_all(:system_id=>system_id)
		Crosspoint.destroy_all(:system_id=>system_id)

        #######################################
        ### UMD                    SYSTEM-AWARE

        Umd.destroy_all(:system_id=>system_id)

        c=0
        64.times  {
          c=c+1
          Umd.new(:intnummer=>c, :kreuzschiene_id=>0, :umdnummer=>"UMD_" + self.formatnumber2(c), :target_id=>0, :system_id=>system_id, :festtext=>"").save
        }

        #######################################
        ### BME                    SYSTEM-AWARE

        Bme.destroy_all(:system_id=>system_id)

        c=0
        72.times  {
          c=c+1
          Bme.new(:taste=>c,:source_id=>0, :system_id=>system_id).save
        }

      end #transaction

  end

  def delete_configuration

      system_id = self.id

      ########################################
      ### FRAMES                  SYSTEM-AWARE
      msg = "Löschung<br/>--------<br/>"

      Frame.destroy_all(:system_id=>system_id)

      msg = msg + "Frames gelöscht<br/>"

      bgs = Bediengeraet.find_all_by_system_id(system_id)
      bgs.each do |b|
        Typesource.destroy_all(:bediengeraet_id=>b)
        Typetarget.destroy_all(:bediengeraet_id=>b)
      end

      Bediengeraet.destroy_all(:system_id=>system_id)

      msg = msg + "Bediengeräte gelöscht<br/>"

      kvs = Kreuzschiene.find_all_by_system_id(system_id)
      kvs.each do |k|
        Source.destroy_all(:kreuzschiene_id=>k)
        Target.destroy_all(:kreuzschiene_id=>k)
      end
      Kreuzschiene.destroy_all(:system_id=>system_id)

      msg = msg + "Kreuzschienen gelöscht<br/>"

      Crosspoint.destroy_all(:system_id=>system_id)

      msg = msg + "XPs gelöscht<br/>"

      Umd.destroy_all(:system_id=>system_id)

      msg = msg + "UMDs gelöscht<br/>"

      Bme.destroy_all(:system_id=>system_id)

      msg = msg + "BMEs gelöscht<br/>"

      MixerTemplate.destroy_all(:system_id=>system_id)

      msg = msg + "Mixer Templates gelöscht<br/>"

      MixerTemplateSetup.destroy_all(:system_id=>system_id)

      msg = msg + "Mixer Template Setups gelöscht<br/>"

      System.delete(system_id)

      msg = msg + "Konfiguration vollständig gelöscht<br/>"

      FileUtils.rm_rf Dir.glob(RAILS_ROOT+ "/conf/#{system_id}/*")
      FileUtils.rm_rf Dir.glob(RAILS_ROOT+ "/conf/#{system_id}")
      if System.count() == 0
        ActiveRecord::Base.connection.execute('ALTER TABLE systems AUTO_INCREMENT = 1')
      end

    return msg

  end

  def write
    @system = self
	FamilyPanel.delete_all("system_id =  #{@system.id}")
	@matrix = Kreuzschiene.find_all_by_system_id(@system.id, :order => 'intnummer ASC')

	@matrix.each do |matrix|
		@sources = Source.find_all_by_kreuzschiene_id(matrix.id)
		@sources.each do |source|
			if source.family_id!=0 && !source.family_id.nil? && !source.family_id.blank?
				FamilyPanel.create(:system_id => @system.id, :matrix => matrix.intnummer, :quellen => source.intnummer, :family => source.family_id, :source_type => "source")
			end
		end
	end

	@matrix.each do |matrix|
		@targets = Target.find_all_by_kreuzschiene_id(matrix.id)
		@targets.each do |target|
			if target.family_id!=0 && !target.family_id.nil? && !target.family_id.blank?
				FamilyPanel.create(:system_id => @system.id, :matrix => matrix.intnummer, :quellen => target.intnummer, :family => target.family_id, :source_type => "target")
			end
		end
	end
    msg = ""

    f = File.new("#{RAILS_ROOT}/conf/ibt.conf", "w")
    #### SYSTEM-AWARE #####
    f.write(@system.version.to_s + "\n")
    msg = msg + "\nVersion: " + @system.version.to_s

    f.write("VERSION=#{Global::VERSION}  \n")
    s_matrix = Option.getSimulateMatrix
    f.write("DEMOSYSTEM \n") if s_matrix.value == "true"
	mv = Option.getMultiViewer
	f.write("TSL_TEXTE=#{mv.value} \n") if mv.value
    f.write(";IBT Steuersystem Configfile V1.0\n")
    f.write(";System UNIT\n")

    @system.frames.each do |@frame|
      if @frame.ipadresse.size>0 then
        if @frame.funktion=="MASTER" then
          f.write("UN_DEF_0" + @frame.intnummer.to_s + "=1," + @frame.ipadresse + ",\"" + @frame.name + "\"\n")
        else
          f.write("UN_DEF_0" + @frame.intnummer.to_s + "=0," + @frame.ipadresse + ",\"" + @frame.name + "\"\n")
        end
      end
    end
    f.write("\n")
    msg = msg + "\n#Frames: " + @system.frames.length.to_s

    #### SYSTEM-AWARE #####
    f.write(";System Kreuzschienen\n")
    @system.kreuzschienes.each do |@kreuzschiene|
      if @kreuzschiene.name.size>0 then
        @kreuzschiene.kr_type == "MIXER" ? kr_type = 1 : @kreuzschiene.kr_type == "MATRIX" ? kr_type = 2 : kr_type = 0
        f.write("KV_DEF_0" + @kreuzschiene.intnummer.to_s + "=" + formatstring(@kreuzschiene.name, 8).to_s + "," + formatnumber2(@kreuzschiene.protocol_id)  + "," + formatnumber3(@kreuzschiene.input) + "," + formatnumber3(@kreuzschiene.output) + "," + formatnumber2(@kreuzschiene.unit) + "," + formatnumber2(@kreuzschiene.port) + "," + formatnumber2(@kreuzschiene.unit2) + "," + formatnumber2(@kreuzschiene.port2) + "," + formatstring(@kreuzschiene.ip, 15) + "," + formatstring(@kreuzschiene.ip2,15) + "," + formatnumber2(kr_type) + "," + formatnumber2(@kreuzschiene.mixer_template_id) + "\n")
      end
    end
    f.write("\n")
    msg = msg + "\n#Kreuzschienen: " + @system.kreuzschienes.length.to_s

    #### Sonder Definitionen #####
    f.write(";Sonder definitionen\n")
    @system.devices.each do |@device|
      if !@device.name.nil? and @device.name.size>0 then
        if @device.protocol_id != 0
			if (!@device.ip.nil? && !@device.ip.blank? && @device.ip.length == 15) || ((!@device.unit.nil? && !@device.unit.blank? && @device.unit!=0) && (!@device.port.nil? && !@device.port.blank? && @device.port!=0))
			#if ((!@device.ip.nil? && !@device.ip.blank? && @device.ip.length != 15) && (!@device.unit.nil? && !@device.unit.blank? && @device.unit!=0))  || ((!@device.unit.nil? && !@device.unit.blank? && @device.unit!=0) && (!@device.port.nil? && !@device.port.blank? && @device.port!=0))
				f.write("SO_DEF_0" + @device.intnummer.to_s + "=" + formatstring(@device.name, 8).to_s + "," + formatnumber2(@device.protocol_id)  + "," + formatnumber2(@device.unit) + "," + formatnumber2(@device.port) + "," + formatstring(@device.ip, 15) + "\n")
			end
        end
      end
    end
    f.write("\n")
    msg = msg + "\n#Devices: " + @system.devices.length.to_s

    #### SYSTEM-AWARE #####
    f.write(";System Bediengeraete_Nr=8Stellig,4Stellig,Unit,Port,Panel_type,Ip,upside_down,vertical,Visible_quellen_pages,Visible_shift_pages,Label_quellen,Font_quellen,Label_split,Font_split,Label_senken,Font_senken\n")
    @system.bediengeraets.each do |@bediengeraet|
      if !@bediengeraet.name8stellig.nil? and @bediengeraet.name8stellig!="" and !@bediengeraet.bdtype_id.nil? and @bediengeraet.bdtype_id>0 then
		typesource = Typesource.find_all_by_bediengeraet_id(@bediengeraet.id, :conditions => ["source_id != 0 and sourcetype = 'normal'"], :order => "id DESC", :limit => "1")
		if typesource.nil? || typesource.blank?
			quellen_page_val = 0
		else
			if @bediengeraet.bdtype_id == 4
				if typesource[0]['tasten_id'].modulo(10) == 0
					quellen_page_val = (typesource[0]['tasten_id']/10)
				else
					quellen_page_val = (typesource[0]['tasten_id']/10).to_i + 1
				end
			elsif @bediengeraet.bdtype_id == 2
				if typesource[0]['tasten_id'].modulo(48) == 0
					quellen_page_val = (typesource[0]['tasten_id']/48)
				else
					quellen_page_val = (typesource[0]['tasten_id']/48).to_i + 1
				end
			elsif @bediengeraet.bdtype_id == 3 || @bediengeraet.bdtype_id == 1 || @bediengeraet.bdtype_id == 5
				if typesource[0]['tasten_id'].modulo(32) == 0
					quellen_page_val = (typesource[0]['tasten_id']/32)
				else
					quellen_page_val = (typesource[0]['tasten_id']/32).to_i + 1
				end
			elsif @bediengeraet.bdtype_id == 6
				if typesource[0]['tasten_id'].modulo(16) == 0
					quellen_page_val = (typesource[0]['tasten_id']/16)
				else
					quellen_page_val = (typesource[0]['tasten_id']/16).to_i + 1
				end
			end
		end
		typetarget = Typetarget.find_all_by_bediengeraet_id(@bediengeraet.id, :conditions => ["target_id != 0"], :order => "id DESC", :limit => "1")
		if typetarget.nil? || typetarget.blank?
			senken_page_val = 0
		else
			if typetarget[0]['tasten_id'].modulo(16) == 0
				senken_page_val = (typetarget[0]['tasten_id']/16)
			else
				senken_page_val = (typetarget[0]['tasten_id']/16).to_i + 1
			end
		end
		if ((!@bediengeraet.ip.nil? && !@bediengeraet.ip.blank? && @bediengeraet.ip.length == 15) && (!@bediengeraet.unit.nil? && !@bediengeraet.unit.blank? && @bediengeraet.unit!=0))|| ((!@bediengeraet.unit.nil? && !@bediengeraet.unit.blank? && @bediengeraet.unit!=0) && (!@bediengeraet.port.nil? && !@bediengeraet.port.blank? && @bediengeraet.port!=0))
			if @bediengeraet.respond_to?("upside_down") && @bediengeraet.respond_to?("vertical") && @bediengeraet.respond_to?("label_quellen") && @bediengeraet.respond_to?("font_quellen") && @bediengeraet.respond_to?("label_split") && @bediengeraet.respond_to?("font_split") && @bediengeraet.respond_to?("label_senken") && @bediengeraet.respond_to?("font_senken")
				f.write("BD_DEF_" + formatnumber2(@bediengeraet.intnummer) + "=" + formatstring(@bediengeraet.name8stellig,8) + "," + formatstring(@bediengeraet.name4stellig,4) +  "," + formatnumber2(@bediengeraet.unit) + "," + formatnumber2(@bediengeraet.port)+ "," + formatnumber2(@bediengeraet.bdtype_id) + "," + formatstring(@bediengeraet.ip, 15) + "," + @bediengeraet.upside_down.to_s + "," + @bediengeraet.vertical.to_s + "," + formatnumber3(quellen_page_val) + "," + formatnumber3(senken_page_val) + "," + formatnumber2(@bediengeraet.label_quellen) + "," + formatnumber2(@bediengeraet.font_quellen) + "," + formatnumber2(@bediengeraet.label_split) + "," + formatnumber2(@bediengeraet.font_split) + "," + formatnumber2(@bediengeraet.label_senken) + "," + formatnumber2(@bediengeraet.font_senken) + "\n")
			elsif @bediengeraet.respond_to?("upside_down") && @bediengeraet.respond_to?("vertical")
				f.write("BD_DEF_" + formatnumber2(@bediengeraet.intnummer) + "=" + formatstring(@bediengeraet.name8stellig,8) + "," + formatstring(@bediengeraet.name4stellig,4) +  "," + formatnumber2(@bediengeraet.unit) + "," + formatnumber2(@bediengeraet.port)+ "," + formatnumber2(@bediengeraet.bdtype_id) + "," + formatstring(@bediengeraet.ip, 15) + "," + @bediengeraet.upside_down.to_s + "," + @bediengeraet.vertical.to_s + "," + formatnumber3(quellen_page_val) + "," + formatnumber3(senken_page_val) + "\n")
			else
				f.write("BD_DEF_" + formatnumber2(@bediengeraet.intnummer) + "=" + formatstring(@bediengeraet.name8stellig,8) + "," + formatstring(@bediengeraet.name4stellig,4) +  "," + formatnumber2(@bediengeraet.unit) + "," + formatnumber2(@bediengeraet.port)+ "," + formatnumber2(@bediengeraet.bdtype_id) + "," + formatstring(@bediengeraet.ip, 15) + "," + "\n")
			end
		end
      end
    end
    f.write("\n")
    msg = msg + "\n#Bediengeraete: " + @system.bediengeraets.length.to_s

    #### SYSTEM-COLOR #####
    @system_colors = SystemColor.find(:all)
    f.write(";Systemcolors_Nr=Red_Value,Green_Value,Blue_Value\n")
    for system_color in @system_colors
	    f.write("SYSCOL_"+formatnumber3(system_color.nummer)+"=" + formatnumber3(system_color.red.to_i/2) + "," + formatnumber3(system_color.green.to_i/2) + "," + formatnumber3(system_color.blue.to_i/2) + "," + formatstring(system_color.name,8) + "\n" )
    end
    f.write("\n\n")

    #### FAMILY #####
    @families = Family.find(:all, :order => "nummer ASC")
    f.write(";Family_Nr=Syscolor,Name_10_char,Rightcontroll\n")
    for family in @families
			f.write("FAMILY_"+formatnumber3(family.nummer)+"=" + formatnumber3(family.system_color_id) + "," + formatstring(family.name,10) + ",255" + "\n" )
    end
    f.write("\n")

   ###############
    # UMD
    #
    #### SYSTEM-AWARE #####

    umds = Umd.find_all_by_system_id(@system.id)
    f.write(";UMD KV Definition:UMD Adr=KV,Senke,Font,Senke/Quelle\n")
    umds.each do |@umd|
      if @umd.kreuzschiene then
        f.write("UMD_DEF_KV_" + formatnumber2(@umd.intnummer) + "=" + formatnumber2(@umd.kreuzschiene.intnummer) + ","+ formatnumber3(@umd.target_id) + ",01,"+ formatnumber2(@umd.choice) +"\n")
      end
    end
    f.write("\n")
    msg = msg + "\n#UMDs: " + @system.umds.length.to_s

    f.write(";UMD Festtext Definition:UMD Adr=Text,Font\n")
    umds.each do |@umd|
      if @umd.festtext!="" then
        f.write("UMD_DEF_TXT_" + formatnumber2(@umd.intnummer) + "=" + formatstring(@umd.festtext,8) + ",01\n")
      end
    end
    f.write("\n")


    f.write(";UMD Mon-US Definition:UMD Adr=Text,Font, GPI-IN\n")
    umds.each do |@umd|
      if !@umd.monitor.nil? and @umd.monitor!="" then
        f.write("UMD_DEF_MON_" + formatnumber2(@umd.intnummer) + "=" + formatstring(@umd.monitor,8) + ",01," + formatnumber2(@umd.gpi.to_i) + "\n")
      end
    end
    f.write("\n")

    f.write(";UMD HAV Betrieb Definition:UMD Adr=Text,Font\n")
    umds.each do |@umd|
      if !@umd.bme.nil? and @umd.bme.strip!="" then
        f.write("UMD_DEF_HAV_" + formatnumber2(@umd.intnummer) + "=" + formatstring(@umd.bme,8) + ",01\n")
      end
    end
    f.write("\n")


    f.write(";UMD KV HAV Betrieb Definition:UMD Adr=Text,Font\n")
    umds.each do |@umd|
      if !@umd.mon_havarie.nil? && !@umd.mon_havarie.blank? && @umd.mon_havarie != "000"
        f.write("UMD_DEF_KVH_" + formatnumber2(@umd.intnummer) + "=" + formatnumber3(@umd.mon_havarie.to_i) + ",01\n")
      end
    end
    f.write("\n")

    #todo
    f.write(";UMD Konfi Betrieb Definition:UMD Adr=Text,Font\n")
    umds.each do |@umd|
      if !@umd.konfiguration.nil? && @umd.konfiguration!="" then
        f.write("UMD_DEF_CON_" + formatnumber2(@umd.intnummer) + "=" + formatstring(@umd.konfiguration,8) + ",03\n")
      end
    end
    f.write("\n")

    f.write(";UMD choice Definition:UMD Adr=Res1,Type,Ip Address,Panel_Nr,Input_Nr,Master_UMD\n")

    umds.each do |@umd|
	 if @umd.type_option.to_i==1 && ((@umd.kreuzschiene!=0 && @umd.target_id !=0) || (!@umd.festtext.nil? && !@umd.festtext.blank?)) then
		f.write("UMD_DEF_CHOICE_" + formatnumber2(@umd.intnummer) + "=0," + formatnumber2(@umd.type_option) + "," + formatstring(@umd.ip_address,15) + "," + formatnumber2(@umd.panel.to_s) + "," + formatnumber2(@umd.vts_input.to_s) + "," + formatnumber2(@umd.master_umd.to_s) + "\n")
	 end
    end
    f.write("\n")

	###############
	# KV01
	#
	#### SYSTEM-AWARE #####

	@kvs = Kreuzschiene.find_all_by_system_id(@system.id, :order=>"intnummer")
	msg = msg + "\nKreuzschienen: " + @kvs.size.to_s

	@kvs.each do |@kv|
		msg = msg + "\nKreuzschiene " + @kv.name
		unless @kv.name=="" then
			f.write(";KV_0" +  @kv.intnummer.to_s + " IN\n")

			if @kv.kr_type == "MATRIX" && !@kv.matrix_type.nil? && @kv.matrix_type.title == "Lawo MONPL"
				@ins = Source.find_all_by_kreuzschiene_id(@kv.id, :order=>"intnummer", :limit=>@kv.input)
				f.write(";KV_I_KvNr_InputNr=Label 1,Label 2,Label 3, Label 4,TallyBit,Audio_follow_video_MatrixNr,Audio_follow_video_QuelleNr,Comment,Audio_follow_video_channel,Family,Enable\n")
				@ins.each do |@in|
					if !@in.name5stellig.nil? && !@in.name5stellig.blank?  then
						if !@in.signal.nil? && !@in.signal.blank? && @in.signal != 0 && SignalQuellen.exists?(["intnummer = ?",@in.signal])
							@signal = sprintf("%03d",SignalQuellen.find_by_intnummer(@in.signal).hexa.to_s)
						else
							@signal = "000"
						end
						f.write("KV_I_0" +  @kv.intnummer.to_s + "_" + formatnumber3(@in.nummer) + "=" + formatstring(@in.name5stellig,8) + "," + formatstring(@in.name4stellig,8) + "," + formatstring(@in.char6,8) + "," + formatstring(@in.char10,10) + "," + formatnumber3(@in.tallybit) +  "," + formatnumber2(@in.matrix.to_i) +  "," + formatnumber3(@in.quelle.to_i) + "," + formatstring(@in.comment,16) + "," + @signal + "," + formatnumber3(@in.subclass) + "," + formatnumber3(@in.component) + "," + formatnumber3(@in.subcomponent) + ","+ formatnumber2(@in.channel) + ","+ formatnumber3(@in.family_id) + "," + @in.enable.to_s + "\n")
					end
				end
			elsif @kv.kr_type == "MATRIX" && !@kv.matrix_type.nil? && @kv.matrix_type.title == "Stagetec"
				@ins = Source.find_all_by_kreuzschiene_id(@kv.id, :order=>"intnummer")
				f.write(";KV_I_KvNr_InputNr=Label 1,Label 2,Label 3, Label 4,TallyBit,Audio_follow_video_MatrixNr,Audio_follow_video_QuelleNr,Comment,Audio_follow_video_channel,Real_input,Family\n")
				@ins.each do |@in|
					if !@in.char10.nil? && !@in.char10.blank?  then
						f.write("KV_I_0" +  @kv.intnummer.to_s + "_" + formatnumber3(@in.nummer) + "=" + formatstring(@in.name5stellig,8) + "," + formatstring(@in.name4stellig,8) + "," + formatstring(@in.char6,8) + "," + formatstring(@in.char10,10) + "," + formatnumber3(@in.tallybit) +  "," + formatnumber2(@in.matrix.to_i) +  "," + formatnumber3(@in.quelle.to_i) + "," + formatstring(@in.comment,16) + "," + formatnumber2(@in.channel)  + "," + formatnumber3(@in.real_input) + "," + formatnumber3(@in.family_id) +"\n")
					end
				end
			elsif @kv.kr_type == "MIXER"
				f.write(";KV_I_KvNr_InputNr=Label 1,Label 2,Label 3, Label 4,TallyBit,Audio_follow_video_MatrixNr,Audio_follow_video_QuelleNr,Comment,Audio_follow_video_channel,Family,Par_Matrix,Par_Quelle\n")
				@ins = Source.find_all_by_kreuzschiene_id(@kv.id, :order=>"intnummer", :limit=>@kv.input)
				@ins.each do |@in|
					if !@in.name5stellig.nil? and @in.name5stellig!="" then
						if @in.respond_to?("par_matrix") && @in.respond_to?("par_quelle") && !@in.par_matrix.nil? && !@in.par_quelle.nil?
							f.write("KV_I_0" +  @kv.intnummer.to_s + "_" + formatnumber3(@in.nummer) + "=" + formatstring(@in.name5stellig,8) + "," + formatstring(@in.name4stellig,8) + "," + formatstring(@in.char6,8) + "," + formatstring(@in.char10,10) + "," + formatnumber3(@in.tallybit) +  "," + formatnumber2(@in.matrix.to_i) +  "," + formatnumber3(@in.quelle.to_i) + "," + formatstring(@in.comment,16) + "," + formatnumber2(@in.channel) + "," + formatnumber3(@in.family_id) +  "," + formatnumber2(@in.par_matrix.to_i) +  "," + formatnumber3(@in.par_quelle.to_i) + "\n" )
						else
							f.write("KV_I_0" +  @kv.intnummer.to_s + "_" + formatnumber3(@in.nummer) + "=" + formatstring(@in.name5stellig,8) + "," + formatstring(@in.name4stellig,8) + "," + formatstring(@in.char6,8) + "," + formatstring(@in.char10,10) + "," + formatnumber3(@in.tallybit) +  "," + formatnumber2(@in.matrix.to_i) +  "," + formatnumber3(@in.quelle.to_i) + "," + formatstring(@in.comment,16) + "," + formatnumber2(@in.channel) + "," + formatnumber3(@in.family_id) + "," + formatnumber2(0) +  "," + formatnumber3(0) + "\n" )
						end
					end
				end
			else
				f.write(";KV_I_KvNr_InputNr=Label 1,Label 2,Label 3, Label 4,TallyBit,Audio_follow_video_MatrixNr,Audio_follow_video_QuelleNr,Comment,Audio_follow_video_channel,Family,Green,Yellow,Blue\n")
				@ins = Source.find_all_by_kreuzschiene_id(@kv.id, :order=>"intnummer", :limit=>@kv.input)
				@ins.each do |@in|
					if !@in.name5stellig.nil? and @in.name5stellig!="" then
						if @in.respond_to?("yellow") && @in.respond_to?("green") && @in.respond_to?("blue")
							f.write("KV_I_0" +  @kv.intnummer.to_s + "_" + formatnumber3(@in.nummer) + "=" + formatstring(@in.name5stellig,10) + "," + formatstring(@in.name4stellig,10) + "," + formatstring(@in.char6,10) + "," + formatstring(@in.char10,10) + "," + formatnumber3(@in.tallybit) +  "," + formatnumber2(@in.matrix.to_i) +  "," + formatnumber3(@in.quelle.to_i) + "," + formatstring(@in.comment,16) + "," + formatnumber2(@in.channel)  + "," + formatnumber3(@in.family_id) + "," + formatnumber3(@in.green) + "," + formatnumber3(@in.yellow) + "," + formatnumber3(@in.blue) + "\n" )
						else
							f.write("KV_I_0" +  @kv.intnummer.to_s + "_" + formatnumber3(@in.nummer) + "=" + formatstring(@in.name5stellig,10) + "," + formatstring(@in.name4stellig,10) + "," + formatstring(@in.char6,10) + "," + formatstring(@in.char10,10) + "," + formatnumber3(@in.tallybit) +  "," + formatnumber2(@in.matrix.to_i) +  "," + formatnumber3(@in.quelle.to_i) + "," + formatstring(@in.comment,16) + "," + formatnumber2(@in.channel)  + "," + formatnumber3(@in.family_id) + "\n" )
						end
					end
				end
			end
			f.write("\n")

			f.write(";KV_0" +  @kv.intnummer.to_s + " OUT\n")

			if @kv.kr_type == "MATRIX" && !@kv.matrix_type.nil? && @kv.matrix_type.title == "Lawo MONPL"
				f.write(";KV_O_KvNr_SenkeNr=Label 1,Label 2,Label 3, Label 4,Audio_follow_video_MatrixNr,Audio_follow_video_QuelleNr,Comment,Audio_follow_video_channel,Family\n")
				@outs = Target.find_all_by_kreuzschiene_id(@kv.id, :order=>"intnummer", :limit=>@kv.output)

				@outs.each do |@out|
					if !@out.name5stellig.nil? and @out.name5stellig!="" then
						if @out.signal != 0
							@signal = sprintf("%03d",SignalSenken.find_by_intnummer(@out.signal).hexa.to_s)
						else
							@signal = "000"
						end
						f.write("KV_O_0" +  @kv.intnummer.to_s + "_" + formatnumber3(@out.nummer) + "=" + formatstring(@out.name5stellig,8) + "," + formatstring(@out.name4stellig,8) + "," + formatstring(@out.char6,8) + "," + formatstring(@out.char10,10) + "," + formatnumber2(@out.matrix.to_i) +  "," + formatnumber3(@out.quelle.to_i) + "," + formatstring(@out.comment,16) + "," + @signal + "," + formatnumber3(@out.subclass) + "," + formatnumber3(@out.component) + "," + formatnumber3(@out.subcomponent) + "," + formatnumber2(@out.channel) + "," + formatnumber3(@out.family_id) + "\n")
					end
				end
			elsif @kv.kr_type == "MATRIX" && !@kv.matrix_type.nil? && @kv.matrix_type.title == "Stagetec"
				f.write(";KV_O_KvNr_SenkeNr=Label 1,Label 2,Label 3, Label 4,Audio_follow_video_MatrixNr,Audio_follow_video_QuelleNr,Comment,Audio_follow_video_channel,Real_output,Family\n")
				@outs = Target.find_all_by_kreuzschiene_id(@kv.id, :order=>"intnummer")

				@outs.each do |@out|
					if !@out.char10.nil? && !@out.char10.blank?  then
						f.write("KV_O_0" +  @kv.intnummer.to_s + "_" + formatnumber3(@out.nummer) + "=" + formatstring(@out.name5stellig,8) + "," + formatstring(@out.name4stellig,8) + "," + formatstring(@out.char6,8) + "," + formatstring(@out.char10,10) + "," + formatnumber2(@out.matrix.to_i) +  "," + formatnumber3(@out.quelle.to_i) + "," + formatstring(@out.comment,16) + "," + formatnumber2(@out.channel) + "," + formatnumber3(@out.real_output) + "," + formatnumber3(@out.family_id) + "\n")
					end
				end
			else
				f.write(";KV_O_KvNr_SenkeNr=Label 1,Label 2,Label 3, Label 4,Audio_follow_video_MatrixNr,Audio_follow_video_QuelleNr,Comment,Audio_follow_video_channel,Family,red,green,yellow,blue\n")
				@outs = Target.find_all_by_kreuzschiene_id(@kv.id, :order=>"intnummer", :limit=>@kv.output)
				@outs.each do |@out|
					if !@out.name5stellig.nil? and @out.name5stellig!="" then
						if @out.respond_to?("red") && @out.respond_to?("green") && @out.respond_to?("yellow") && @out.respond_to?("blue")
							f.write("KV_O_0" +  @kv.intnummer.to_s + "_" + formatnumber3(@out.nummer) + "=" + formatstring(@out.name5stellig,8) + "," + formatstring(@out.name4stellig,8) + "," + formatstring(@out.char6,8) + "," + formatstring(@out.char10,10) + "," + formatnumber2(@out.matrix.to_i) +  "," + formatnumber3(@out.quelle.to_i) + "," + formatstring(@out.comment,16) + "," + formatnumber2(@out.channel) + "," + formatnumber3(@out.family_id) + "," + @out.red.to_s + "," + @out.green.to_s + "," + @out.yellow.to_s + "," + @out.blue.to_s + "\n")
						else
							f.write("KV_O_0" +  @kv.intnummer.to_s + "_" + formatnumber3(@out.nummer) + "=" + formatstring(@out.name5stellig,8) + "," + formatstring(@out.name4stellig,8) + "," + formatstring(@out.char6,8) + "," + formatstring(@out.char10,10) + "," + formatnumber2(@out.matrix.to_i) +  "," + formatnumber3(@out.quelle.to_i) + "," + formatstring(@out.comment,16) + "," + formatnumber2(@out.channel) + "," + formatnumber3(@out.family_id) + "\n")
						end
					end
				end
			end
			f.write("\n")

			f.write(";Tally Clones = Kv_Nr,Quelle,Clone_Quelle \n")

			@ins.each do |@in|
				if !@in.name5stellig.nil? and @in.name5stellig!="" and !@in.cloneinput.blank? and !@in.cloneinput.nil? then
					#@val = @clone_id.id-@row+1
					f.write("CLON_TALLY=" + formatnumber2(@kv.intnummer) + "," + formatnumber3(@in.intnummer) +  "," + formatnumber3(@in.cloneinput) + "\n")
				end
			end
			f.write("\n")

		end
	end

	#######################
	# SALVO Section
	#
	#### SYSTEM-AWARE #####

	# ;Salvo Definition KV_SS_SalvoNr=Name 10char

	f.write(";Salvo Definition KV_SS_SalvoNr=Name\n")
	@slv = Salvo.find_all_by_system_id(@system.id)
	@slv.each do |@sl|
		f.write("KV_SS_" + formatnumber3(@sl.intnummer) + "=" + formatstring(@sl.name,10) + "\n" )
	end
	f.write("\n")

	# ;Salov Konfiguration KV_S_SalnoNr=Futureuse1,RowNr,Matrix,Senke,Quelle,Futureuse2_char3,Futureuse3
	# KV_S_001=01,003,01,003,003,"   ",001
	f.write(";Salov Konfiguration KV_S_SalnoNr=SalvoType,RowNr,Matrix,Senke,Quelle,Stack+Frame+Slot_char7_Class,HLSD_Subclas,HLSD_Component,HLSD_Subcomponent,,HLSD_char7_class,HLSD_Subclas,HLSD_Component,HLSD_Subcomponent\n")
	@slv.each do |@sl|
		@setups = Crosspoint.find_all_by_salvo_id_and_system_id(@sl.intnummer, @system.id)
		@setups.each do |@st|
			if @sl.salvo_type.to_i==0
				if @st && !@st.kreuzschiene_id.nil? && !@st.source_id.nil? && !@st.target_id.nil?
					kv = @st.kreuzschiene.intnummer
					sr = @st.source.intnummer
					tr = @st.target.intnummer

	#				f.write("KV_S_" + formatnumber3(@sl.intnummer) + "=" + formatnumber2(1) + "," + formatnumber3(@st.nummer) + "," +  formatnumber2(kv) + "," + formatnumber3(tr) + "," + formatnumber3(sr) + "," + formatstring(nil, 3) + "," + formatnumber3(1) +  "\n" )
					f.write("KV_S_" + formatnumber3(@sl.intnummer) + "=" + get_salvo_type(@sl.intnummer) + "," + formatnumber3(@st.nummer) + "," +  formatnumber2(kv) + "," + formatnumber4(tr) + "," + formatnumber4(sr) + "," + formatstring(nil, 3) + "," + formatnumber3(1) +  "\n" )
				end
			elsif @sl.salvo_type.to_i==1
					f.write("KV_S_" + formatnumber3(@sl.intnummer) + "=" + get_salvo_type(@sl.intnummer) + "," + formatnumber3(@st.nummer) + "," +  formatnumber2(0) + "," + formatnumber4(0) + "," + formatnumber4(0) + "," + formatstring(@st.stack.to_s + "." + @st.frame.to_s + "." + @st.slot.to_s,10) + "," + formatnumber3(@st.source_subclass) + "," + formatnumber3(@st.source_component) + "," + formatnumber3(@st.source_subcomponent) + "," + formatstring(@st.stack.to_s + "." + @st.frame.to_s + "." + @st.slot.to_s,10) + "," + formatnumber3(@st.dest_subclass) + "," + formatnumber3(@st.dest_component) + "," + formatnumber3(@st.dest_subcomponent) + "," + formatstring(@st.parameter,32) + "," + formatstring(@st.value,32) + "," + formatstring(@st.comment,16) + "\n")
			elsif @sl.salvo_type.to_i==2
					f.write("KV_S_" + formatnumber3(@sl.intnummer) + "=" + get_salvo_type(@sl.intnummer) + "," + formatnumber3(@st.nummer) + "," +  formatnumber2(0) + "," + formatnumber4(@st.delay) + "," + formatnumber4(0) + "," + formatstring(@st.source_single_class,10) + "," + formatnumber3(@st.source_subclass) + "," + formatnumber3(@st.source_component) + "," + formatnumber3(@st.source_subcomponent) + "," + formatstring(@st.dest_single_class,10) + "," + formatnumber3(@st.dest_subclass) + "," + formatnumber3(@st.dest_component) + "," + formatnumber3(@st.dest_subcomponent) + "," + formatstring(@st.parameter,32) + "," + formatstring(@st.value,32) + "," + formatstring(@st.comment,16) + "\n")
			end
		end
	end
	f.write("\n")
	if !@sl.nil?
		msg = msg + "\n#Salov Konfiguration: " + @sl.intnummer.to_s
	end

    ###############
    # MIXER / BME #
    #
    #### SYSTEM-AWARE #####
    f.write(";MI_01 Tastenbelegung TastenNr=Quelle KV_01\n")
    @bmes = Bme.find_all_by_system_id(@system.id)
    @bmes.each do |@bme|
      if !@bme.source_id.nil? and @bme.source_id>0 then
        f.write("MI_T_01_" + formatnumber3(@bme.taste) + "=" + formatnumber3(@bme.source_id) + "\n")
      end
    end
    f.write("\n")
    msg = msg + "\n#Mixer: " + @bmes.length.to_s

    ###############
    # BD-Geraete  #
    #
    #### SYSTEM-AWARE #####

    @bgs = Bediengeraet.find_all_by_system_id(@system.id)

    @bgs.each do |@bg|
      #begin
      if !@bg.name8stellig.nil? and @bg.name8stellig!="" and @bg.bdtype_id.to_i>0 and @bg.normalquellen_kv_id then

        # ---- #
        kv = Kreuzschiene.getMatrix(@bg.normalquellen_kv_id, @system.id)
        unless kv.nil? then
          kv_intnummer = kv.intnummer
        else
          kv_intnummer = "FEHLER"
          msg = msg + "\n#BD-Export FEHLER: Kreuzschiene nicht gefundern: " + @bg.normalquellen_kv_id.to_s
        end
        #f.write(";DB: " + @bg.name8stellig + "\n")

        @normalquellen = Typesource.find_all_by_bediengeraet_id_and_sourcetype(@bg, "normal")
        @splitquellen = Typesource.find_all_by_bediengeraet_id_and_sourcetype(@bg, "split")
        @senken = Typetarget.find_by_bediengeraet_id(@bg)
		@panel_function = PanelFunction.find_by_bediengeraet_id(@bg)
        if @senken.nil? then
          @senken = Typetarget.new(:target_id=>"FEHLER")
        end

        f.write(";BD_0" + @bg.intnummer.to_s + " Quellentastenbelegung Normalbetrieb\n")
        # ALLE TYPEN Normalquellen
        if @bg.bdtype_id < 3 or @bg.bdtype_id == 4
            @normalquellen.each do |@nq|
              if !@nq.nil? and !@nq.source_id.nil? and @nq.source_id>0 then
                f.write("BD_QTN_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@nq.tasten_id) + "=" + formatnumber2(kv_intnummer) +"," + formatnumber3(@senken.target_id) + "," + formatnumber3(@nq.source_id) + "\n")
              end
            end
        else
            if @bg.bdtype_id == 3
                @normalquellen.each do |@nq|
                  if !@nq.nil? and !@nq.source_id.nil? && @nq.source_id>0 then
                    f.write("BD_QTN_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@nq.tasten_id) + "=" + formatnumber2(@nq.matrix) +"," + formatnumber3(@nq.source_id) + "\n")
                  end
                end
			elsif @bg.bdtype_id == 6
				@normalquellen.each do |@nq|
				   if !@nq.nil? and !@nq.source_id.nil? and @nq.source_id>0 then
					        f.write("BD_QTN_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@nq.tasten_id) + "=" + formatnumber2(kv_intnummer) +"," + formatnumber3(@senken.target_id) + "," + formatnumber3(@nq.source_id) + "\n")
					   end
				end
			    f.write("\n")
				if !@panel_function.nil?
					if @panel_function.family == 1 && @panel_function.audis == 1
						f.write(";FUNCTION_KEY_Panel_Nr_Functionkey_Nr=Name,Button Nr \n")
						f.write('FUNCTION_KEY_02_01="SHIFT",' + Global::SHIFT_TYPE_6.to_s + "\n")
						f.write('FUNCTION_KEY_02_02="FAMLY",' + Global::FAMILY_TYPE_6.to_s + "\n")
						f.write('FUNCTION_KEY_02_03="AUDIS",' + Global::AUDIS_TYPE_6.to_s + "\n")
					elsif @panel_function.family == 1
						f.write(";FUNCTION_KEY_Panel_Nr_Functionkey_Nr=Name,Button Nr \n")
						f.write('FUNCTION_KEY_02_01="SHIFT",' + Global::SHIFT_TYPE_6.to_s + "\n")
						f.write('FUNCTION_KEY_02_02="FAMLY",' + Global::FAMILY_TYPE_6.to_s + "\n")
					elsif @panel_function.audis == 1
						f.write(";FUNCTION_KEY_Panel_Nr_Functionkey_Nr=Name,Button Nr \n")
						f.write('FUNCTION_KEY_02_01="SHIFT",' + Global::SHIFT_TYPE_6.to_s + "\n")
						f.write('FUNCTION_KEY_02_03="AUDIS",' + Global::AUDIS_TYPE_6.to_s + "\n")
					end
				end
            else
                @normalquellen.each do |@nq|
                  if !@nq.nil? and !@nq.source_id.nil? and @nq.source_id>0 then
                    f.write("BD_QTN_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@nq.tasten_id) + "=" + formatnumber2(kv_intnummer) +"," + formatnumber3(@nq.source_id) + "\n")
                  end
                end
            end
        end
        f.write("\n")

        if @bg.bdtype_id==2 or @bg.bdtype_id==3 or @bg.bdtype_id==5 then
          # Spltquellen nur bei Typ  2,3,5
          f.write(";BD_0" + @bg.intnummer.to_s + " Quellenbelegung Splitbetrieb\n")
          if @bg.bdtype_id>1 then
            @splitquellen.each do |@nq|
              begin
                if !@nq.nil? and @nq.source_id>0 then
                  if @bg.bdtype_id==2
                    f.write("BD_QTS_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@nq.tasten_id) + "=" + formatnumber2(kv_intnummer) + "," + formatnumber3(@senken.target_id) + "," + formatnumber3(@nq.source_id) + "\n")
                  elsif @bg.bdtype_id == 3
                    f.write("BD_QTS_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@nq.tasten_id) + "=" + formatnumber2(@nq.matrix) + "," + formatnumber3(@nq.source_id) + "\n")
                  else
                    f.write("BD_QTS_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@nq.tasten_id) + "=" + formatnumber2(kv_intnummer) + "," + formatnumber3(@nq.source_id) + "\n")
                  end
                end
              rescue
                msg = msg + "\n>>FEHLER BD_0" + @bg.intnummer.to_s
              end
            end
          end
          f.write("\n")
        end

#       if @bg.bdtype_id>2 and @bg.bdtype_id<4 then
        if @bg.bdtype_id==3 or @bg.bdtype_id==5 or @bg.bdtype_id==6 then
          f.write(";BD_0" + @bg.intnummer.to_s + " Senkentastenbelegung Splitbetrieb\n")
          @senken = Typetarget.find_all_by_bediengeraet_id(@bg)
          if @bg.bdtype_id==3
              @senken.each do |@senke|
                if !@senke.nil? and !@senke.target_id.nil? and @senke.target_id>0 then
                  f.write("BD_STN_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@senke.tasten_id) + "=" + formatnumber2(@senke.matrix) +"," + formatnumber3(@senke.target_id) + "\n")
                end
              end
          else
              @senken.each do |@senke|
                if !@senke.nil? and !@senke.target_id.nil? and @senke.target_id>0 then
                  f.write("BD_STN_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@senke.tasten_id) + "=" + formatnumber2(kv_intnummer) +"," + formatnumber3(@senke.target_id) + "\n")
                end
              end

			f.write("\n")
			if @bg.bdtype_id==5
				if !@panel_function.nil?
					if @panel_function.family == 1 && @panel_function.audis == 1
						f.write(";FUNCTION_KEY_Panel_Nr_Functionkey_Nr=Name,Button Nr \n")
						f.write('FUNCTION_KEY_02_01="SHIFT",'+ Global::SHIFT_TYPE_5.to_s + "\n")
						f.write('FUNCTION_KEY_02_02="FAMLY",'+ Global::FAMILY_TYPE_5.to_s + "\n")
						f.write('FUNCTION_KEY_02_03="AUDIS",' + Global::AUDIS_TYPE_5.to_s + "\n")
					elsif @panel_function.family == 1
						f.write(";FUNCTION_KEY_Panel_Nr_Functionkey_Nr=Name,Button Nr \n")
						f.write('FUNCTION_KEY_02_01="SHIFT",' + Global::SHIFT_TYPE_5.to_s + "\n")
						f.write('FUNCTION_KEY_02_02="FAMLY",' + Global::FAMILY_TYPE_5.to_s + "\n")
					elsif @panel_function.audis == 1
						f.write(";FUNCTION_KEY_Panel_Nr_Functionkey_Nr=Name,Button Nr \n")
						f.write('FUNCTION_KEY_02_01="SHIFT",' + Global::SHIFT_TYPE_5.to_s + "\n")
						f.write('FUNCTION_KEY_02_03="AUDIS",' + Global::FAMILY_TYPE_5.to_s + "\n")
					end
				end
			end
          end
        end
        f.write("\n")
      end
      #rescue
      #end
    end
    f.write("\n")

	f.write(";SENDE_BD = panel_id, matrix_id, senke_id \n")
	@bgs.each do |@bg|
		if @bg.bdtype_id == 3
			if (!@bg.sende_matrix_id.nil? || !@bg.sende_matrix_id.blank?) && (!@bg.sende_senke_id.nil? || !@bg.sende_senke_id.blank?)
				f.write("SENDE_BD="+ formatnumber3(@bg.intnummer) + "," + formatnumber2(@bg.sende_matrix_id) + "," + formatnumber3(@bg.sende_senke_id) + "\n")
			end
		end
	end
	f.write("\n")

	@tallies = @system.tallies
	if !@tallies.nil?
		@tallies.each do |@tally|
			if (!@tally.kreuzschiene_id.nil? || !@tally.kreuzschiene_id.blank?) && (!@tally.senke_id.nil? || !@tally.senke_id.blank?)
				if @tally.name == "RED_TALLY"
					f.write("; KV_HAV_TALLY=Matrix Nr two digits,dependend output Nr three digits \n")
					f.write("KV_HAV_TALLY="+ formatnumber2(@tally.kreuzschiene_id) + "," + formatnumber3(@tally.senke_id) + "\n")
				else
					f.write("; #{@tally.name}=Matrix Nr two digits,dependend output Nr three digits \n")
					f.write("#{@tally.name}="+ formatnumber2(@tally.kreuzschiene_id) + "," + formatnumber3(@tally.senke_id)+ "\n")
				end
			end
		end
	end
	f.write("\n")

=begin	@mixer_tallies = @system.mixer_tallies
	if !@mixer_tallies.nil?
		@mixer_tallies.each do |mixer_tally|
			if (!mixer_tally.kreuzschiene_id.nil? || !mixer_tally.kreuzschiene_id.blank?) && (!mixer_tally.senke_id.nil? || !mixer_tally.senke_id.blank?)
				if mixer_tally.name == "RED_TALLY"
					f.write("; MIXER_RED_TALLY=Matrix Nr two digits,dependend output Nr three digits \n")
					f.write("MIXER_RED_TALLY="+ formatnumber2(mixer_tally.kreuzschiene_id) + "," + formatnumber3(mixer_tally.senke_id) + "\n")
				else
					f.write("; MIXER_#{mixer_tally.name}=Matrix Nr two digits,dependend output Nr three digits \n")
					f.write("MIXER_#{mixer_tally.name}="+ formatnumber2(mixer_tally.kreuzschiene_id) + "," + formatnumber3(mixer_tally.senke_id)+ "\n")
				end
			end
		end
	end
	f.write("\n")
=end

	# if option is set
	@opt = Option.getTallyOption
	if !@opt.nil? && @opt.value == "yes"
		f.write("FORCE_MODE_HAV \n")
	end
	f.write("\n")

	# UMD_PGM_TALLY
	f.write(";UMD_PGM_TALLY \n")
	@umds = Umd.find(:all, :conditions => ["pgm_monitor =?", "1"], :select => "id, intnummer")
	@umds.each do |u|
		f.write("UMD_PGM_TALLY=" + formatnumber2(u.intnummer) + "\n")
	end

	f.write("\n")

	# peview_monitor
	# MIX_TAST= intnummer, senke of kv1
	f.write(";MIX_TAST \n")

	@bmes = Bme.find(:all, :conditions => ["peview_monitor IS NOT NULL and system_id = #{@system.id}"], :select => "id, taste, peview_monitor")
	#@bmes = Bme.find(:all, :conditions => ["system_id = #{@system.id}"], :select => "id, taste, peview_monitor")
	@bmes.each do |b|
		f.write("MIX_TAST=" + formatnumber2(b.taste) +","+ formatnumber3(b.peview_monitor) + "\n")
	end
	f.write("\n")

	# kr_type = MIXER

	@kvs = Kreuzschiene.find_all_by_system_id(@system.id, :order=>"intnummer")
	msg = msg + "\nKreuzschienen: " + @kvs.size.to_s

	@kvs.each do |@kv|
		msg = msg + "\nMixer type Kreuzschiene " + @kv.name
		unless @kv.name=="" then
			if @kv.kr_type == "MIXER" || @kv.kr_type == "MATRIX" || @kv.kr_type == ""
				f.write(";KV_REE_QUELLE_" + @kv.intnummer.to_s + "\n")
				f.write(";KV_REE_QUELLE=Kv,Quelle,Reentry_Kv,Reentry_Quelle,Enable \n")
				@ins = Source.find_all_by_kreuzschiene_id(@kv.id, :order=>"intnummer", :select => "intnummer, mx_matrix, mx_senke, enable", :limit=>@kv.input)
				@ins.each do |@in|
					if !@in.mx_matrix.nil? && !@in.mx_matrix.blank? && !@in.mx_senke.nil? && !@in.mx_senke.blank?
						f.write("KV_REE_QUELLE=" + formatnumber2(@kv.intnummer) + "," + formatnumber3(@in.intnummer) + "," + formatnumber2(@in.mx_matrix) + "," + formatnumber3(@in.mx_senke) + "," + @in.enable.to_s + "\n" )
					end
				end
				f.write("\n")

				f.write(";KV_REE_SENKE_" + @kv.intnummer.to_s + "\n")
				f.write(";KV_REE_SENKE=KvNr,Senke,Ziel_KvNr,Ziel_Quelle,Senke \n")
				@outs = Target.find_all_by_kreuzschiene_id(@kv.id, :order=>"intnummer", :select => "intnummer, mx_tallybit, mx_matrix, mx_quelle", :limit=>@kv.output)

				@outs.each do |@out|
					if !@out.mx_matrix.nil? && !@out.mx_matrix.blank? && !@out.mx_quelle.nil? && !@out.mx_quelle.blank?
						f.write("KV_REE_SENKE=" + formatnumber2(@kv.intnummer) + "," + formatnumber3(@out.intnummer) + "," + formatnumber2(@out.mx_matrix) + "," + formatnumber3(@out.mx_quelle) + "," + formatnumber3(@out.intnummer) + "\n" )
					end
				end
				f.write("\n")
			else
				f.write(";KV_REE_SENKE_" + @kv.intnummer.to_s + "\n")
				@outs = Target.find_all_by_kreuzschiene_id(@kv.id, :order=>"intnummer", :select => "intnummer, mx_matrix, mx_quelle", :limit=>@kv.output)

				@outs.each do |@out|
					if !@out.mx_matrix.nil? && !@out.mx_matrix.blank? && !@out.mx_quelle.nil? && !@out.mx_quelle.blank?
						f.write("KV_REE_SENKE=" + formatnumber2(@kv.intnummer) + "," + formatnumber3(@out.intnummer) + "," + formatnumber2(@out.mx_matrix) + "," + formatnumber3(@out.mx_quelle) + "\n" )
					end
				end
				f.write("\n")
			end
		end
	end
	@system_matching = SystemMatching.find_all_by_system_id(@system.id, :order => 'intnummer ASC')
	f.write("\n")
	f.write(";MATCHING_Matching_set=Panel_Nr,Start,Stop,Matrix,Senke\n")
	@system_matching.each do |matching|
		f.write("MATCHING_" + matching.matching_set.to_s + "=" + formatnumber3(matching.matching_panel) + "," + formatnumber2(matching.matching_start_quelle) + "," + formatnumber2(matching.matching_end_quelle) + "," + formatnumber2(matching.matching_matrix) + "," + formatnumber3(matching.matching_senke) + "\n")
	end

	@system_assoziation = SystemAssoziation.find_all_by_system_id(@system.id, :order => 'intnummer ASC')
	f.write("\n")
	f.write(";ASSOZIATION_DEF_Nr=Matrix,Senke,Matrix,Senke,Matrix,Senke,Matrix,Senke\n")
	@system_assoziation.each do |assoziation|
		f.write("ASSOZIATION_DEF_" + formatnumber3(assoziation.intnummer) + "=" + formatnumber2(assoziation.source_matrix) + "," + formatnumber3(assoziation.source_senke) + "," + formatnumber2(assoziation.matrix_1) + "," + formatnumber3(assoziation.senke_1) + "," + formatnumber2(assoziation.matrix_2) + "," + formatnumber3(assoziation.senke_2) + "," + formatnumber2(assoziation.matrix_3) + "," + formatnumber3(assoziation.senke_3) + "\n")
	end

  f.write("\n")
  f.write(";COLLECT_FAMILY_FONT=Label,Font\n")
  font, label = Option.find_by_title('family_font'), Option.find_by_title('family_label')
  f.write("COLLECT_FAMILY_FONT=#{formatnumber2(label.value)},#{formatnumber2(font.value)}\n")

	f.write("\n")
	f.write(";COLLECT_FAMILY_QUELLE_Matrix_Nr=Family_Nr,Quelle\n")
	@family_member_quelle = FamilyPanel.find_all_by_system_id(@system.id, :joins => "left join families on families.nummer = family_panels.family", :conditions => ["family_panels.source_type = 'source'"], :order => 'family_panels.matrix, families.position, family_panels.quellen ASC')
	@family_member_quelle.each do |quelle_panel|
		f.write("COLLECT_FAMILY_QUELLE_" + formatnumber2(quelle_panel.matrix) + "=" + formatnumber3(quelle_panel.family) + "," + formatnumber4(quelle_panel.quellen) + "\n")
	end

	f.write("\n")
	f.write(";COLLECT_FAMILY_SENKE_Matrix_Nr=Family_Nr,Senke\n")
	@family_member_senken = FamilyPanel.find_all_by_system_id(@system.id, :joins => "left join families on families.nummer = family_panels.family", :conditions => ["family_panels.source_type = 'target'"], :order => 'family_panels.matrix, families.position, family_panels.quellen ASC')
	@family_member_senken.each do |senke_panel|
		f.write("COLLECT_FAMILY_SENKE_" + formatnumber2(senke_panel.matrix) + "=" + formatnumber3(senke_panel.family) + "," + formatnumber4(senke_panel.quellen) + "\n")
	end

	f.write("\n")
	# Option Page :: ibt content
	f.write("; Special section for unsupported GUI comand or test \n")
	@content = Option.getIbtContent
	opt = @content.value.split("\n")
	opt.each do |p|
		f.write("GUI_#{p.strip}\n")
	end
	f.write("\n")

	f.close

	if @system.version.nil? then
		@system.version = 0
	else
		@system.version = @system.version + 1
	end
	@system.version = 1 if @system.version > 255
	@system.save

	if !File.directory?("#{RAILS_ROOT}/conf/#{@system.id}")
		Dir.mkdir("conf/#{@system.id}")
		File.open( "conf/#{@system.id}/gpio.txt", "w" )
		File.open( "conf/#{@system.id}/gpio.conf", "w" )
		File.open( "conf/#{@system.id}/ibt.conf", "w" )
	end

	f_new_conf = File.new("#{RAILS_ROOT}/conf/gpio.conf","w")

	File.open("#{RAILS_ROOT}/conf/#{@system.id}/gpio.conf", 'r').each do |e|
		f_new_conf.write(e)
	end

	f_new_txt = File.new("#{RAILS_ROOT}/conf/gpio.txt","w")

	File.open("#{RAILS_ROOT}/conf/#{@system.id}/gpio.txt", 'r').each do |e|
		f_new_txt.write(e)
	end

	f_new_ibt = File.new("#{RAILS_ROOT}/conf/#{@system.id}/ibt.conf","w")

	File.open("#{RAILS_ROOT}/conf/ibt.conf", 'r').each do |e|
		f_new_ibt.write(e)
	end
    ### Write-Protokoll
	m = File.new("#{RAILS_ROOT}/log/conf.protocol.txt", "w")
	m.write(msg)
    	m.close

    return msg
  end

  def write_old
      @system = self
    msg = ""

    f = File.new("#{RAILS_ROOT}/conf/ibt.conf", "w")

    #### SYSTEM-AWARE #####
    f.write(@system.version.to_s + "\n")
    msg = msg + "\nVersion: " + @system.version.to_s
    f.write(";IBT Steuersystem Configfile V1.0\n")
    f.write(";System UNIT\n")
    @system.frames.each do |@frame|
      if @frame.ipadresse.size>0 then
        if @frame.funktion=="MASTER" then
          f.write("UN_DEF_0" + @frame.intnummer.to_s + "=1," + @frame.ipadresse + ",\"" + @frame.name + "\"\n")
        else
          f.write("UN_DEF_0" + @frame.intnummer.to_s + "=0," + @frame.ipadresse + ",\"" + @frame.name + "\"\n")
        end
      end
    end
    f.write("\n")
    msg = msg + "\n#Frames: " + @system.frames.length.to_s

    #### SYSTEM-AWARE #####
    f.write(";System Kreuzschienen\n")
    @system.kreuzschienes.each do |@kreuzschiene|
      if @kreuzschiene.name.size>0 then
        f.write("KV_DEF_0" + @kreuzschiene.intnummer.to_s + "=" + formatstring(@kreuzschiene.name, 8).to_s + "," + formatnumber2(@kreuzschiene.protocol_id)  + "," + formatnumber3(@kreuzschiene.input)  + "," + formatnumber3(@kreuzschiene.output)  + "," + formatnumber2(@kreuzschiene.unit)  + "," + formatnumber2(@kreuzschiene.port)  + "," + formatnumber2(@kreuzschiene.unit2)  + "," + formatnumber2(@kreuzschiene.port2)  + "\n")
      end
    end
    f.write("\n")
    msg = msg + "\n#Kreuzschienen: " + @system.kreuzschienes.length.to_s

	#### SYSTEM-AWARE #####
	f.write(";System Bediengeraete\n")
	@system.bediengeraets.each do |@bediengeraet|
	  if !@bediengeraet.name8stellig.nil? and @bediengeraet.name8stellig!="" and !@bediengeraet.bdtype_id.nil? and @bediengeraet.bdtype_id>0 then
		if (!@bediengeraet.unit.nil? && !@bediengeraet.unit.blank? && @bediengeraet.unit!=0) && (!@bediengeraet.port.nil? && !@bediengeraet.port.blank? && @bediengeraet.port!=0)
			f.write("BD_DEF_" + formatnumber2(@bediengeraet.intnummer) + "=" + formatstring(@bediengeraet.name8stellig,8) + "," + formatstring(@bediengeraet.name4stellig,4) + "," + formatnumber2(@bediengeraet.unit) + "," + formatnumber2(@bediengeraet.port) + "," + formatnumber2(@bediengeraet.bdtype_id) + "\n")
		end
	  end
	end
	f.write("\n")
	msg = msg + "\n#Bediengeraete: " + @system.bediengeraets.length.to_s

    ###############
    # UMD
    #
    #### SYSTEM-AWARE #####

    umds = Umd.find_all_by_system_id(@system.id)

    f.write(";UMD KV Definition:UMD Adr=KV,Senke,Font\n")
    umds.each do |@umd|
      if @umd.kreuzschiene then
        f.write("UMD_DEF_KV_" + formatnumber2(@umd.intnummer) + "=" + formatnumber2(@umd.kreuzschiene.intnummer) + ","+ formatnumber3(@umd.target_id) + ",01\n")
      end
    end
    f.write("\n")
    msg = msg + "\n#UMDs: " + @system.umds.length.to_s


    f.write(";UMD Festtext Definition:UMD Adr=Text,Font\n")
    umds.each do |@umd|
      if @umd.festtext!="" then
        f.write("UMD_DEF_TXT_" + formatnumber2(@umd.intnummer) + "=" + formatstring(@umd.festtext,8) + ",01\n")
      end
    end
    f.write("\n")


    f.write(";UMD Mon-US Definition:UMD Adr=Text,Font, GPI-IN\n")
    umds.each do |@umd|
      if !@umd.monitor.nil? and @umd.monitor!="" then
        f.write("UMD_DEF_MON_" + formatnumber2(@umd.intnummer) + "=" + formatstring(@umd.monitor,8) + ",01," + formatnumber2(@umd.gpi.to_i) + "\n")
      end
    end
    f.write("\n")

    f.write(";UMD HAV Betrieb Definition:UMD Adr=Text,Font\n")
    umds.each do |@umd|
      if !@umd.bme.nil? and @umd.bme.strip!="" then
        f.write("UMD_DEF_HAV_" + formatnumber2(@umd.intnummer) + "=" + formatstring(@umd.bme,8) + ",01\n")
      end
    end
    f.write("\n")


    f.write(";UMD KV HAV Betrieb Definition:UMD Adr=Text,Font\n")
    umds.each do |@umd|
      if !@umd.mon_havarie.nil? && !@umd.mon_havarie.blank? && @umd.mon_havarie != "000"
        f.write("UMD_DEF_KVH_" + formatnumber2(@umd.intnummer) + "=" + formatstring(@umd.mon_havarie,8) + ",01\n")
      end
    end
    f.write("\n")

    #todo
    f.write(";UMD Konfi Betrieb Definition:UMD Adr=Text,Font\n")
    umds.each do |@umd|
      if !@umd.konfiguration.nil? && @umd.konfiguration!="" then
        f.write("UMD_DEF_CON_" + formatnumber2(@umd.intnummer) + "=" + formatstring(@umd.konfiguration,8) + ",03\n")
      end
    end
    f.write("\n")

    ###############
    # KV01
    #
    #### SYSTEM-AWARE #####

    @kvs = Kreuzschiene.find_all_by_system_id(@system.id, :order=>"intnummer")
    msg = msg + "\nKreuzschienen: " + @kvs.size.to_s

    @kvs.each do |@kv|
      msg = msg + "\nKreuzschiene " + @kv.name

	  unless @kv.name=="" then
		f.write(";KV_0" +  @kv.intnummer.to_s + " IN\n")
		@ins = Source.find_all_by_kreuzschiene_id(@kv.id, :order=>"intnummer", :limit=>@kv.input)

		@ins.each do |@in|
			if !@in.name5stellig.nil? and @in.name5stellig!="" then
				f.write("KV_I_0" +  @kv.intnummer.to_s + "_" + formatnumber3(@in.nummer) + "=" + formatstring(@in.name5stellig,8) + "," + formatstring(@in.name4stellig,8) + 	"," + formatstring(@in.name4stellig,8) + "," + formatstring(@in.name4stellig,10) + "," +  formatstring(@in.name4stellig,16) + "\n")
			end
		end

		f.write("\n")

		f.write(";KV_0" +  @kv.intnummer.to_s + " OUT\n")
		@outs = Target.find_all_by_kreuzschiene_id(@kv.id, :order=>"intnummer", :limit=>@kv.output)
		@outs.each do |@out|
		  if !@out.name5stellig.nil? and @out.name5stellig!="" then
			f.write("KV_O_0" +  @kv.intnummer.to_s + "_" + formatnumber3(@out.nummer) + "=" + formatstring(@out.name5stellig,8) + "," + formatstring(@out.name4stellig,8) + 	"," + formatstring(@out.name4stellig,8) + "," + formatstring(@out.name4stellig,10) + "," +  formatstring(@out.name4stellig,16) + "\n")
		  end
		end
		f.write("\n")
	  end
    end

    ###############
    # XP Setup    #
    #
    #### SYSTEM-AWARE #####

    f.write(";XP_Setup Xp-Nr=KV,Senke,Quelle\n")
    @cps = Crosspoint.find_all_by_system_id(@system.id)
    @cps.each do |@cp|
      if !@cp.kreuzschiene_id.nil? and @cp.kreuzschiene_id>0 and !@cp.source.nil? and !@cp.target.nil? then
        f.write("KV_S_01_" + formatnumber3(@cp.nummer) + "=" + formatnumber2(@cp.kreuzschiene.intnummer) + "," + formatnumber3(@cp.target.intnummer) + "," + formatnumber3(@cp.source.intnummer) + "\n")
      end
    end
    f.write("\n")
    msg = msg + "\n#Crosspoints: " + @cps.length.to_s


    ###############
    # MIXER / BME #
    #
    #### SYSTEM-AWARE #####
    f.write(";MI_01 Tastenbelegung TastenNr=Quelle KV_01\n")
    @bmes = Bme.find_all_by_system_id(@system.id)
    @bmes.each do |@bme|
      if !@bme.source_id.nil? and @bme.source_id>0 then
        f.write("MI_T_01_" + formatnumber3(@bme.taste) + "=" + formatnumber3(@bme.source_id) + "\n")
      end
    end
    f.write("\n")
    msg = msg + "\n#Mixer: " + @bmes.length.to_s


    ###############
    # BD-Geraete  #
    #
    #### SYSTEM-AWARE #####

    @bgs = Bediengeraet.find_all_by_system_id(@system.id)

    @bgs.each do |@bg|
      #begin
      if !@bg.name8stellig.nil? and @bg.name8stellig!="" and @bg.bdtype_id.to_i>0 and @bg.normalquellen_kv_id then

        kv = Kreuzschiene.getMatrix(@bg.normalquellen_kv_id, @system.id)
        unless kv.nil? then
          kv_intnummer = kv.intnummer
        else
          kv_intnummer = "FEHLER"
          msg = msg + "\n#BD-Export FEHLER: Kreuzschiene nicht gefundern: " + @bg.normalquellen_kv_id.to_s
        end
        #f.write(";DB: " + @bg.name8stellig + "\n")

        @normalquellen = Typesource.find_all_by_bediengeraet_id_and_sourcetype(@bg, "normal")
        @splitquellen = Typesource.find_all_by_bediengeraet_id_and_sourcetype(@bg, "split")
        @senken = Typetarget.find_by_bediengeraet_id(@bg)

        if @senken.nil? then
          @senken = Typetarget.new(:target_id=>"FEHLER")
        end

        f.write(";BD_0" + @bg.intnummer.to_s + " Quellentastenbelegung Normalbetrieb\n")
        # ALLE TYPEN Normalquellen
        if @bg.bdtype_id < 3 or @bg.bdtype_id == 4 then
          @normalquellen.each do |@nq|
            #senke_intnummer =
            begin
              if !@nq.nil? and @nq.source_id>0 then
                f.write("BD_QTN_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@nq.tasten_id) + "=" + formatnumber2(kv_intnummer) +"," + formatnumber3(@senken.target_id) + "," + formatnumber3(@nq.source_id) + "\n")
              end
            rescue
              msg = msg + "\n>>FEHLER BD_0" + @bg.bdtype_id.to_s
            end
          end
        else
          @normalquellen.each do |@nq|
            if !@nq.nil? and @nq.source_id>0 then
              f.write("BD_QTN_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@nq.tasten_id) + "=" + formatnumber2(kv_intnummer) +"," + formatnumber3(@nq.source_id) + "\n")
            end
          end
        end
        f.write("\n")

        if @bg.bdtype_id==2 or @bg.bdtype_id==3 or @bg.bdtype_id==5  then
          # Spltquellen nur bei Typ  2,3,5
          f.write(";BD_0" + @bg.intnummer.to_s + " Quellenbelegung Splitbetrieb\n")
          if @bg.bdtype_id>1 then
            @splitquellen.each do |@nq|
              begin
                if !@nq.nil? and @nq.source_id>0 then
                  if @bg.bdtype_id==2 then
                    f.write("BD_QTS_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@nq.tasten_id) + "=" + formatnumber2(kv_intnummer) + "," + formatnumber3(@senken.target_id) + "," + formatnumber3(@nq.source_id) + "\n")
                  else
                    f.write("BD_QTS_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@nq.tasten_id) + "=" + formatnumber2(kv_intnummer) + "," + formatnumber3(@nq.source_id) + "\n")
                  end
                end
              rescue
                msg = msg + "\n>>FEHLER BD_0" + @bg.intnummer.to_s
              end
            end
          end
          f.write("\n")
        end

#       if @bg.bdtype_id>2 and @bg.bdtype_id<4 then
        if @bg.bdtype_id==3 or @bg.bdtype_id==5 then
          f.write(";BD_0" + @bg.intnummer.to_s + "Senkentastenbelegung Splitbetrieb\n")
          @senken = Typetarget.find_all_by_bediengeraet_id(@bg)
          @senken.each do |@senke|
            if !@senke.nil? and @senke.target_id>0 then
              f.write("BD_STN_" + formatnumber2(@bg.intnummer) + "_" + formatnumber3(@senke.tasten_id) + "=" + formatnumber2(kv_intnummer) +"," + formatnumber3(@senke.target_id) + "\n")
            end
          end
        end
        f.write("\n")

      end

      #rescue
      #end
    end

    f.close

    if @system.version.nil? then
      @system.version = 0
    else
      @system.version = @system.version + 1
    end
    @system.version = 1 if @system.version > 255

    @system.save

    ### Write-Protokoll
    m = File.new("#{RAILS_ROOT}/log/conf.protocol.txt", "w")
    m.write(msg)
    m.close

    return msg
  end

end
