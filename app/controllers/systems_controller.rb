class SystemsController < ApplicationController
  require 'rubygems'
  require 'rbconfig'
  require 'pathname'
  require 'fileutils'
  require 'date'
  require 'time'
  require 'zip/zip'
  require 'zip/zipfilesystem'

  if Config::CONFIG['target_os'] != 'linux'
     require 'win32ole'
     require 'ruby-wmi'
  end


  def clear_systems
		Bediengeraet.destroy_all
		Bg.destroy_all
		Bme.destroy_all
		Crosspoint.destroy_all
		Frame.destroy_all
		Kreuzschiene.destroy_all
		Source.destroy_all
		System.destroy_all
		Target.destroy_all
		Typ1.destroy_all
		Typ2.destroy_all
		Typ3.destroy_all
		Typ4.destroy_all
		Typ5.destroy_all
		Typesource.destroy_all
		Typetarget.destroy_all
		Umd.destroy_all

		flash[:notice] = 'Es wurden alle Konfigurationen gelöscht'

		respond_to do |format|
			format.html { redirect_to :controller=>'systems', :action => "index" }
		end

  end


  def update
		@system = System.find(params[:id])

		if @system.update_attributes(params[:system])
			flash[:notice] = 'System wurde gespeichert'
		else
			flash[:notice] = 'FEHLER'
		end

		respond_to do |format|
			format.html { redirect_to :controller=>'systems', :action => "index" }
		end
  end

  def update_tally
		@tally = Tally.find(params[:tally][:id])
		@update_senke == 0

		if !params[:tally][:kreuzschiene_id].nil? && @tally.kreuzschiene_id != params[:tally][:kreuzschiene_id]
			@update_senke = 1
		end
		@tally.update_attributes(params[:tally])

		render :update do |page|
			if @update_senke == 1
				page.replace_html "sn_#{@tally.id}", :partial => "getSenke", :locals => {:kv_tally => @tally.kreuzschiene_id}
			end
		end
  end

  def update_mixer_tally
		@mixer_tally = MixerTally.find(params[:mixer_tally][:id])
		@update_senke == 0

		if !params[:mixer_tally][:kreuzschiene_id].nil? && @mixer_tally.kreuzschiene_id != params[:mixer_tally][:kreuzschiene_id]
			@update_senke = 1
		end
		@mixer_tally.update_attributes(params[:mixer_tally])

		render :update do |page|
			if @update_senke == 1
				page.replace_html "sn_mixer_#{@mixer_tally.id}", :partial => "getSenke_mixer", :locals => {:kv_tally => @mixer_tally.kreuzschiene_id}
			end
		end
  end
  # Leere Konfiguration anlegen
  def create
		newsys = System.new(params[:system])
		newsys.save

		newsys.build_clean_configuration(params[:start_ip])

		cookies[:system_id] = newsys.id.to_s
		@system = System.find(newsys.id)

		#MixerTemplate.build_mixer_template(newsys.id)
		#MixerTemplateSetup.build_mixer_template_setup(newsys.id)


		if File.directory?("#{RAILS_ROOT}/conf/#{@system.id}")
			FileUtils.rm_rf Dir.glob(RAILS_ROOT+ "/conf/#{@system.id}/*")
			FileUtils.rm_rf Dir.glob(RAILS_ROOT+ "/conf/#{@system.id}")
		end


		Dir.mkdir("conf/#{@system.id}")

		File.open( "conf/#{@system.id}/gpio.txt", "w" ) do |f|
		# TODO Do write something here
		end

		File.open( "conf/#{@system.id}/gpio.conf", "w" ) do |f|
		# TODO Do write something here.
		end

		i=1
		3.times do
			SystemMatching.create(:system_id => @system.id, :intnummer => i)
			SystemAssoziation.create(:system_id => @system.id, :intnummer => i)
		i+=1
		end
		respond_to do |format|
			format.html { redirect_to :action => "index" }
		end
  end

  # Leere Konfiguration anlegen
  def delete_configuration
	  sys = System.find(params[:id])
	  msg = sys.delete_configuration
	  flash[:notice] = msg

	  respond_to do |format|
		  format.html { redirect_to :action => "index" }
	  end
  end

  def download
		@system = System.find(params[:id])
		@system.write
		FileUtils.rm_rf Dir.glob("#{RAILS_ROOT}/conf/#{params[:id]}/configuration.zip")
		zip_them_all = ZipThemAll.new("#{RAILS_ROOT}/conf/#{params[:id]}/configuration.zip","#{RAILS_ROOT}/conf/#{params[:id]}/")
		zip_them_all.zip
		send_file "#{RAILS_ROOT}/conf/#{params[:id]}/configuration.zip", :type=>"application/zip"
	end

	def import_configuration
		if request.post?
			fd = params[:upload]
			path = File.join("#{RAILS_ROOT}/conf/#{params[:id]}/", fd.original_filename)
			File.open(path, "wb") { |f| f.write(fd.read) }
			unzip_file("#{RAILS_ROOT}/conf/#{params[:id]}/configuration.zip", "#{RAILS_ROOT}/conf/#{params[:id]}/")
			FileUtils.rm_rf Dir.glob("#{RAILS_ROOT}/conf/#{params[:id]}/configuration.zip")
			Dir.foreach("#{RAILS_ROOT}/conf/#{params[:id]}/") {|x|
						if x!='.' && x!='..' && File.directory?("#{RAILS_ROOT}/conf/#{params[:id]}/#{x}")
							FileUtils.mv("#{RAILS_ROOT}/conf/#{params[:id]}/#{x}/gpio.conf", "#{RAILS_ROOT}/conf/#{params[:id]}/gpio.conf")
							FileUtils.mv("#{RAILS_ROOT}/conf/#{params[:id]}/#{x}/gpio.txt", "#{RAILS_ROOT}/conf/#{params[:id]}/gpio.txt")
							FileUtils.mv("#{RAILS_ROOT}/conf/#{params[:id]}/#{x}/ibt.conf", "#{RAILS_ROOT}/conf/#{params[:id]}/ibt.conf")
							FileUtils.mv("#{RAILS_ROOT}/conf/#{params[:id]}/ibt.conf", "#{RAILS_ROOT}/conf/ibt.conf")
							FileUtils.rm_rf Dir.glob("#{RAILS_ROOT}/conf/#{params[:id]}/#{x}")
						end
			}
			@system = System.find(params[:id])
			import(id=@system.id)
		end
	end

  def show
		cookies[:system_id] = params[:id]

		@system = System.find(params[:id])
		if SystemMatching.count(:conditions => ["system_id = #{@system.id}"]) == 0
			i=1
			3.times do
				SystemMatching.create(:system_id => @system.id, :intnummer => i)
			i+=1
			end
		end

		if SystemAssoziation.count(:conditions => ["system_id = #{@system.id}"]) == 0
			i=1
			3.times do
				SystemAssoziation.create(:system_id => @system.id, :intnummer => i)
			i+=1
			end
		end

		@system_matchings = SystemMatching.find_all_by_system_id(@system.id, :order => 'intnummer ASC')
		@system_assoziations = SystemAssoziation.find_all_by_system_id(@system.id, :order => 'intnummer ASC')

		@opt_tally = Option.getTallyOption
		@kr_type = ["MATRIX", "MIXER"]
		@tpls = MixerTemplate.find(:all, :order => "intnummer").map {|u| [u.name, u.intnummer]}
		@m_types = MatrixType.getMatrixTypes.map {|u| [u.title, u.intnummer]}

		@units = get_units

		if session[:display].nil? || session[:display]=='name' then
			@protocols = Protocol.find(:all).map {|u| [u.name, u.id]}
			@kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and nummer!='' and name!=''", cookies[:system_id]], :order=>'intnummer').map {|u| [u.name, u.intnummer]}
		else
			@protocols = Protocol.find(:all).map {|u| [u.id, u.id]}
			@kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and nummer!='' and name!=''", cookies[:system_id]], :order=>'intnummer').map {|u| [u.intnummer, u.intnummer]}
		end

		respond_to do |format|
			format.html { render :action => "show" }
		end
  end

  def get_ports
	  s_id = params[:s_id]
	  opt = params[:opt].to_i
	  html_id = "port#{opt}_#{s_id}"

	  if [6, 7].include? opt
		  @ports = (1..Global::MAX_PORT).to_a
	  else
		  @ports = validateUnitPort(params[:curr_unit].to_i, params[:curr_port].to_i)
	  end

	  odds = (1..Global::MAX_PORT).to_a.mod_val(2, 1)
	  evens = (1..Global::MAX_PORT).to_a.mod_val(2, 0)

	  render :update do |page|
		  case opt
			  when 1
				  obj_name = "kreuzschiene"
				  field = "port"
				  submit_id = "k#{s_id}"
				  kr = Kreuzschiene.find(s_id)
				  @ports = @ports.delete_all(odds) if !kr.protocol.nil? && kr.protocol.protocol_type_id == 2
				  @ports = @ports.delete_all(evens) if !kr.protocol.nil? && kr.protocol.protocol_type_id == 1
				  page["k#{params[:s_id]}"].click
			  when 2
				  obj_name = "kreuzschiene"
				  field = "port2"
				  submit_id = "k#{s_id}"
				  kr = Kreuzschiene.find(s_id)
				  @ports = @ports.delete_all(odds) if !kr.protocol.nil? && kr.protocol.protocol_type_id == 2
				  @ports = @ports.delete_all(evens) if !kr.protocol.nil? && kr.protocol.protocol_type_id == 1
				  page["k#{params[:s_id]}"].click
			  when 3
				  obj_name = "device"
				  field = "port"
				  submit_id = "d#{s_id}"
				  dv = Device.find(s_id)
				  @ports = @ports.delete_all(odds) if !dv.protocol.nil? && dv.protocol.protocol_type_id == 2
				  @ports = @ports.delete_all(evens) if !dv.protocol.nil? && dv.protocol.protocol_type_id == 1
				  page["d#{params[:s_id]}"].click
			  when 4

				  obj_name = "bediengeraet"
				  field = "port"
				  submit_id = "submitchangeitem#{s_id}"

			  when 5
				  obj_name = "gp_input"
				  field = "port"
				  submit_id = ""

			  when 6
				  obj_name = "input"
				  field = "port"
				  submit_id = "submitchangeitem#{s_id}"

			  when 7
				  obj_name = "output"
				  field = "port"
				  submit_id = "submitchangeoutput#{s_id}"
		  end
		  page.replace_html "#{html_id}", :partial => "shared/port_listbox", :locals => {:submit_id => submit_id, :curr_port => params[:curr_port].to_i, :obj_name => obj_name, :field => field, :show => "listbox", :opt => opt}
		  if opt==6 || opt==7
			page["#{submit_id}"].click
		  end
	  end
  end

  def show_clean
		cookies[:system_id] = params[:id]
		@system = System.find(params[:id])

		respond_to do |format|
			format.html { redirect_to :controller=>"bediengeraets", :action => "show" }
		end
  end


  def setadmin
		session[:mode]="admin"
		respond_to do |format|
			format.html { redirect_to :action => "index" }
		end
  end


  def setuser
		session[:mode]="user"
		respond_to do |format|
			format.html { redirect_to :action => "index" }
		end
  end

  def setibt_admin
		if session[:mode]=='ibt-admin'
			respond_to do |format|
				format.html { redirect_to :action => "index" }
			end
		else
			if request.post?
				if params[:password]=='ibt'
					session[:mode]="ibt-admin"
					respond_to do |format|
						format.html { redirect_to :action => "index" }
					end
				else
					flash[:error] = "Please enter valid password"
					redirect_to :action => 'setibt_admin'
				end
			end
		end
  end
  # Daten aus dem System lesen
  def ftptransfer

    require 'net/ftp'
    require 'timeout'

    ftpdest = "<font color='black'><b>Übertragungsstatus</b><br />"

    system_id = cookies[:system_id]
    @system = System.find(system_id)

    @system.write

    @system.frames.each do |@frame|
      if @frame.ipadresse.size>0 then

        veto = 0
        logger.info(">>FTP: " + @frame.ipadresse + " " + Global::FTPUSER + " " + Global::FTPPASSWD)
        ftp = nil
        begin
          timeout(Global::CON_TIMEOUT) do
            logger.info(">>FTP: trying to connect")
           ftp = Net::FTP::new(@frame.ipadresse)
           ftp.login(Global::FTPUSER, Global::FTPPASSWD)
          end
          logger.info(">>FTP connect successfully " + @frame.ipadresse)

        rescue Net::FTPPermError => msg
          ftpdest = ftpdest + "<font color='red'>Fehler Login: " + @frame.ipadresse + "</font><br />"
          logger.info(">>FTP error connect ")
          veto = 1
          ftp.close if ftp
          GC.start
          sleep Global::CLOSE_TIMEOUT

        rescue Timeout::Error => msg
          ftpdest = ftpdest + "<font color='red'>Fehler Timeout: " + @frame.ipadresse + "</font><br />"
          logger.info(">>FTP error connect ")
          veto = 1
          ftp.close if ftp
          GC.start
          sleep Global::CLOSE_TIMEOUT
        end


        # Bei Verbindung Daten holen versuchen
        unless veto==1 then

          begin
            timeout(Global::TRANSFER_TIMEOUT) do
              logger.info(">>FTP: trying to transfer (get)")
              ftp.chdir(Global::FTPDIR)
              ftp.putbinaryfile("#{RAILS_ROOT}/conf/ibt.conf", "ibt.conf")
	      if File.exists?("#{RAILS_ROOT}/conf/#{@system.id}/gpio.conf")
		      ftp.putbinaryfile("#{RAILS_ROOT}/conf/#{@system.id}/gpio.conf", "gpio.conf")
	      end

	      if File.exists?("#{RAILS_ROOT}/conf/#{@system.id}/gpio.txt")
		      ftp.putbinaryfile("#{RAILS_ROOT}/conf/#{@system.id}/gpio.txt", "gpio.txt")
	      end
            end

            logger.info(">>FTP: done for " + @frame.ipadresse)
            ftpdest = ftpdest + "<font color='green'><b>Übertragung nach " + @frame.ipadresse + " erfolgreich</b></font><br />"

          rescue Timeout::Error => msg
            logger.info(">>FTP error " + msg)
            ftpdest = ftpdest + "<font color='red'>Fehler1 Übertragung nach " + @frame.ipadresse + "<br />" + "</font>"

          rescue

            ftpdest = ftpdest + "<font color='red'>Fehler2 Übertragung nach " + @frame.ipadresse + "<br />" + "</font>"

          ensure
            ftp.close if ftp
            GC.start
            sleep Global::CLOSE_TIMEOUT
          end

        end

      end
    end

    flash[:notice]= "<fieldset>" + ftpdest + "</font></fieldset>"

    respond_to do |format|
      format.html { redirect_to :action => "show", :id=>system_id }
    end

  end


  # Daten aus dem System lesen
  def ftp_get_from_system

    require 'net/ftp'
    require 'timeout'

    f = File.open("#{RAILS_ROOT}/log/ftp_transfer.log", 'w')

    system_id =params[:id]
    finish = false
    ftpdest=""

    @system = System.find(system_id)
    f.write("System " + @system.id.to_s + "\n")

    @system.frames.each do |@frame|
      f.write("----==============----\n")
      f.write("Frame " + "#" + @frame.intnummer.to_s + " " + @frame.ipadresse.to_s + "\n")
      if @frame.ipadresse.size>0 and finish==false then
        f.write(">>FTP: " + @frame.ipadresse.to_s + " user:" + Global::FTPUSER.to_s + " pass:" + Global::FTPPASSWD.to_s + " dir:" + Global::FTPDIR.to_s + "\n")
        veto = false
        ftp = nil
        begin
          timeout(Global::CON_TIMEOUT) do
            f.write(">>FTP: trying to connect to " + @frame.ipadresse.to_s + "\n")
            ftp = Net::FTP::new(@frame.ipadresse)
            ftp.login(Global::FTPUSER, Global::FTPPASSWD)
          end
          f.write(">>FTP connect successfully " + @frame.ipadresse.to_s + "\n")

        rescue Net::FTPPermError => msg
          ftpdest = ftpdest + "<font color='red'>Fehler Login: " + @frame.ipadresse.to_s + "</font><br />"
          f.write(">>FTP connect FAILED " + @frame.ipadresse.to_s + " by PermissionError\n")

          veto = 1
          ftp.close if ftp
          GC.start
          sleep Global::CLOSE_TIMEOUT

        rescue Timeout::Error => msg
          f.write(">>FTP connect FAILED " + @frame.ipadresse.to_s + " by TimeOut\n")
          veto = true

          ftp.close if ftp
          GC.start
          sleep Global::CLOSE_TIMEOUT

        rescue => msg
          f.write(">>FTP connect FAILED " + @frame.ipadresse.to_s + " by " + msg + "\n")
          veto = true

          ftp.close if ftp
          GC.start
          sleep Global::CLOSE_TIMEOUT
        end



        # Bei Verbindung Daten holen versuchen
        unless veto==true then
          f.write(">> -NO- veto\n")

          begin
            timeout(Global::TRANSFER_TIMEOUT) do
              f.write(">>FTP trying Transfer " + @frame.ipadresse.to_s + "\n")

              ftp.chdir(Global::FTPDIR)
              ftp.getbinaryfile("ibt.conf", "#{RAILS_ROOT}/conf/ibt.conf", 1024)


              if !File.directory?("#{RAILS_ROOT}/conf/#{@system.id}")
                Dir.mkdir("#{RAILS_ROOT}/conf/#{@system.id}")
              end
	      if File.exists?("gpio.conf")
		      ftp.getbinaryfile("gpio.conf", "#{RAILS_ROOT}/conf/#{@system.id}/gpio.conf", 1024)
	      else
		      File.new("conf/#{@system.id}/gpio.conf","w")
	      end
	      if File.exists?("gpio.txt")
		      ftp.getbinaryfile("gpio.txt", "#{RAILS_ROOT}/conf/#{@system.id}/gpio.txt", 1024)
	      else
		      File.new("#{RAILS_ROOT}/conf/#{@system.id}/gpio.txt","w")
	      end


              ftpdest = @frame.ipadresse
            end

            f.write(">>FTP: done for " + @frame.ipadresse.to_s + "\nTrying import\n")
            finish = true

            # Dann auch wirklich importieren
            import(ftpdest)

            f.write(">>Import done\n")

          rescue Timeout::Error => msg
            f.write(">>FTP1 error " + msg + "\n")
          rescue => msg
            f.write(">>FTP2 error " + msg + "\n")
          ensure

            f.write(">>FTP3 ensure ftp.close\n")

            ftp.close if ftp
            GC.start
            sleep Global::CLOSE_TIMEOUT

          end

        end

      end
    end

    unless finish==true then
      f.write(">>No TRANSFER, finish!=true\n")
      flash[:notice]="Es konnte keine Konfiguration eingelesen werden"
      respond_to do |format|
		 	format.html { redirect_to :action => "show", :id=>system_id }
      end
    end
    f.close
  end

  def write

	msg = "Protokoll:"
	system_id = params[:id]
	@system = System.find(system_id)
	@vs_nr = Option.getIbtVersionOption
	if @vs_nr.value.to_i == 0
		@system.write_old
	else
		@system.write
	end
	flash[:notice]="System wurde als Version " + @system.version.to_s + " im projektverzeichnis gespeichert "
	respond_to do |format|
		format.html { redirect_to :action => "show", :id=>system_id }
	end
  end

  ##############################################################################
  ##############################################################################
  ##############################################################################
  ##############################################################################

  def import(datasource="conf/ibt.conf")

		system_id = params[:id]
		@vs_nr = Option.getIbtVersionOption



		begin
			currsystem = System.find(system_id)
		rescue
			currsystem = System.create(:name=>"System " + system_id.to_s, :version=>1)
			currsystem.save
		end

		log = File.open("#{RAILS_ROOT}/log/import_log.txt", 'w')

		currsystem.build_clean_configuration("")

		log.write("----==============----\n")
		log.write("System " + currsystem.id.to_s + "\n")

		msg = ""
		zeile = 0
		ibt_content = ""

		f = File.open("conf/ibt.conf", 'r')

		# durchgeschlurtes BG
		b = Bediengeraet.new
		ts1 = Typesource.new
		ts2 = Typesource.new
		SystemColor.destroy_all
		Family.destroy_all
		SystemMatching.delete_all("system_id = #{system_id}")
		SystemAssoziation.delete_all("system_id = #{system_id}")
		tt = Typetarget.new

		System.transaction do
		#begin
		  f.each do |line_complete|

				line_complete.split(/\r/).each do |line|
				if zeile==0 then
				  currsystem.update_attribute(:version, line)
				end
				zeile = zeile + 1
				log.write(zeile.to_s + " >> " + line.to_s + "\n")

				if !line.nil? and line.strip == "DEMOSYSTEM"
					s_matrix = Option.getSimulateMatrix
					s_matrix.update_attributes(:value => "true")
				end

				if !line.nil? and line.strip.length>5 and line[0]!=";" then
				  tupel = line.delete('"').strip.split("=")
				  defi = tupel[0].split("_")

				  if line.to_s.slice(0, 4) == "GUI_"
						ibt_content << line.strip.slice(4..-1).to_s << "\n"
				  end

				  ### Tally section ReadBack ###
				  if Global::READBACKTALLY.include? tupel[0].strip
						attribut = tupel[1].split(",")

						if tupel[0].strip == "KV_HAV_TALLY"
						  tally_name = "RED_TALLY"
						else
						  tally_name = tupel[0].strip
						end

						tl = Tally.find_by_name_and_system_id(tally_name, system_id)
						tl.update_attributes(:kreuzschiene_id => attribut[0].to_i, :senke_id => attribut[1].to_i )
		  		end

	  			if tupel[0].strip == "TSL_TEXTE"
						mv = Option.getMultiViewer
						mv.update_attributes(:value => tupel[1].strip)
		  		end

				  ########

				  ###### UN_DEF
				  ## Frames                                      (SYSTEM-AWARE!)
				  if defi[0]=="UN" and defi[1]=="DEF" then

						attribut = tupel[1].split(",")
						f = Frame.find_by_intnummer_and_system_id(defi[2].to_i, system_id)
						unless f.nil? then
							f.update_attributes(:name=>'UNIT ' + attribut[0].to_s, :ipadresse=>attribut[1])
						end

				  # Kreuzschienen                               (SYSTEM-AWARE!)
				  elsif defi[0]=="KV" and defi[1]=="DEF" then

						attribut = tupel[1].split(",")
						k = Kreuzschiene.find_by_intnummer_and_system_id(defi[2].to_i, system_id)

						unless k.nil? then
							Source.destroy_all(:kreuzschiene_id=>k)
							Target.destroy_all(:kreuzschiene_id=>k)

						  if k.name = "Stagetec"
							 k.create_io_stagetek
							else
							 k.create_io
							end

							if attribut.size < 12

								k.update_attributes(:nummer=>'KV_0' + defi[2].to_i.to_s, :name=>attribut[0].to_s.strip, :protocol_id => attribut[1].to_s, :input => attribut[2].to_s, :output =>attribut[3].to_s,:unit => attribut[4].to_i,:port => attribut[5].to_i, :unit2 => attribut[6].to_i, :port2 => attribut[7].to_i, :ip => attribut[8].to_s, :ip2 => attribut[9].to_s)
							else
								attribut[10].to_i == 1 ? kr_type = "MIXER" : attribut[10].to_i == 2 ? kr_type = "MATRIX" : kr_type = ""

								k.update_attributes(:nummer=>'KV_0' + defi[2].to_i.to_s, :name=>attribut[0].to_s.strip, :protocol_id => attribut[1].to_s, :input => attribut[2].to_s, :output =>attribut[3].to_s,:unit => attribut[4].to_i,:port => attribut[5].to_i, :unit2 => attribut[6].to_i, :port2 => attribut[7].to_i, :ip => attribut[8].to_s, :ip2 => attribut[9].to_s, :kr_type => kr_type, :mixer_template_id => attribut[11])

							end
						end

				  # Devices   (SYSTEM-AWARE!)
				  elsif defi[0]=="SO" and defi[1]=="DEF" then

						attribut = tupel[1].split(",")
						d = Device.find_by_intnummer_and_system_id(defi[2].to_i, system_id)

						unless d.nil? then
							d.update_attributes(:nummer=>'DEV_0' + defi[2].to_i.to_s, :name=>attribut[0].to_s.strip, :protocol_id => attribut[1].to_i, :unit => attribut[2].to_i,:port => attribut[3].to_i, :ip => attribut[4].to_s)
						end

				  # Bediengeräte
				  elsif defi[0]=="BD" then

						attribut = tupel[1].split(",")

						if defi[1]=="DEF" then

					  if (!b.nil? and b.intnummer!=defi[2].to_i) then
							b = Bediengeraet.getBediengeraet(defi[2].to_i, system_id)
					  end

					  unless b.nil? then
							if b.respond_to?("label_quellen") && b.respond_to?("font_quellen") && b.respond_to?("label_split") && b.respond_to?("font_split")	&& b.respond_to?("label_senken")	&& b.respond_to?("font_senken")
				 				b.update_attributes(:nummer=>'BD_' + formatnumber2(defi[2].to_i), :name8stellig=>attribut[0].to_s.strip, :name4stellig=>attribut[1].to_s.strip,:unit=>attribut[2].to_s, :port=>attribut[3].to_s, :ip => attribut[5].to_s, :bdtype_id=>attribut[4].to_s, :upside_down => attribut[6].to_s, :vertical => attribut[7].to_s, :label_quellen => attribut[10].to_s, :font_quellen => attribut[11].to_s, :label_split => attribut[12].to_s, :font_split => attribut[13].to_s, :label_senken => attribut[14].to_s, :font_senken => attribut[15].to_s)
							else
								b.update_attributes(:nummer=>'BD_' + formatnumber2(defi[2].to_i), :name8stellig=>attribut[0].to_s.strip, :name4stellig=>attribut[1].to_s.strip,:unit=>attribut[2].to_s, :port=>attribut[3].to_s, :ip => attribut[5].to_s, :bdtype_id=>attribut[4].to_s, :upside_down => attribut[6].to_s, :vertical => attribut[7].to_s)
							end
							currsystem.createBDTypDummy(b.id,attribut[4].to_i)
							log.write("BD-DEF " + defi[2].to_i.to_s + " bid:" + b.id.to_s + " typ:" + attribut[4].to_i.to_s + "\n")
					  end

					elsif (defi[1]=="QTN") then

					  log.write("BD-QTN " + defi[2].to_i.to_s + " searching\n")

					  if (!b.nil? and b.intnummer!=defi[2].to_i) then
							b = Bediengeraet.getBediengeraet(defi[2].to_i, system_id)
							log.write("BD-QTN " + defi[2].to_i.to_s + " found\n")
					  end

					  if (!ts1.nil? and (ts1.bediengeraet_id.to_i!=b.id.to_i or ts1.tasten_id.to_i!=defi[3].to_i)) then
							ts1 = Typesource.find_by_bediengeraet_id_and_tasten_id_and_sourcetype(b.id, defi[3].to_i, 'normal')
							log.write("retrieving TS\n")
					  end
					  #if (!tt.nil? and (tt.bediengeraet_id!=b.id or tt.tasten_id!=defi[3].to_i)) then
						tt = Typetarget.find_by_bediengeraet_id_and_tasten_id(b.id, defi[3].to_i)
					  #end

					  prot = b.bdtype_id

					  unless b.nil? and b.normalquellen_kv_id==0 then
							kv = Kreuzschiene.find_by_intnummer_and_system_id(attribut[0], system_id)
							b.update_attribute('normalquellen_kv_id', kv.intnummer)
							log.write("BD-QTN Normalquellenupdate" + kv.intnummer.to_s + "\n")
					  end

					  log.write("BD-QTN prot: " + prot.to_s + "\n")

			  		if prot<3 or prot==4 then
						# Sonderfall BD_TYP_1/2, hier ist das
							unless ts1.nil? then
							  ts1.update_attributes(:source_id=>attribut[2])
							  log.write("BD-QTN TS_update 1" + attribut[2].to_s + "\n")

							end
							unless tt.nil? then
							  tt.update_attributes(:target_id=>attribut[1])
							end
					  elsif prot == 3
							# Sonderfall BD_TYP_3/4, hier ist das
							unless ts1.nil? then
							  ts1.update_attributes(:matrix => attribut[0], :source_id=>attribut[1])
							  log.write("BD-QTN TS_update 2" + attribut[2].to_s + "\n")
							end
					  elsif prot == 6
							unless ts1.nil? then
							  ts1.update_attributes(:source_id=>attribut[2])
							  log.write("BD-QTN TS_update 1" + attribut[2].to_s + "\n")
							end
					  else
							unless ts1.nil? then
							  ts1.update_attributes(:source_id=>attribut[1])
							  log.write("BD-QTN TS_update 2" + attribut[2].to_s + "\n")
							end
					  end

				elsif (defi[1]=="QTS") then

				  log.write("BD-QTS " + defi[2].to_i.to_s + " searching\n")
				  if (!b.nil? and b.intnummer!=defi[2].to_i) then
						b = Bediengeraet.getBediengeraet(defi[2].to_i, system_id)
						log.write("BD-QTS " + defi[2].to_i.to_s + " found\n")
				  end

				  if (!ts2.nil? and (ts2.bediengeraet_id.to_i!=b.id.to_i or ts2.tasten_id.to_i!=defi[3].to_i)) then
						ts2 = Typesource.find_by_bediengeraet_id_and_tasten_id_and_sourcetype(b.id, defi[3].to_i, 'split')
						log.write("retrieving TS\n")
				  end

				  if (!tt.nil? and (tt.bediengeraet_id!=b.id or tt.tasten_id!=defi[3].to_i)) then
						tt = Typetarget.find_by_bediengeraet_id_and_tasten_id(b.id, defi[3].to_i)
				  end

				  #prot = ts.bediengeraet.bdtype_id
				  prot = b.bdtype_id
					unless b.nil? and b.splitquellen_kv_id.nil? then
						kv = Kreuzschiene.find_by_intnummer_and_system_id(attribut[0], system_id)
						b.update_attribute('splitquellen_kv_id', kv.intnummer)
			  	end

			  	log.write("BD-QTS prot: " + prot.to_s + "\n")
			  	if prot<3 or prot==4 then

						unless ts2.nil? then
						  ts2.update_attributes(:source_id=>attribut[2])
						  log.write("BD-QTS " + b.id.to_s + " TS_update 3" + attribut[2].to_s + "\n")
						end
				# Sonderfall BD_TYP_1/2, hier ist das
						unless tt.nil? then
						  tt.update_attributes(:target_id=>attribut[2])
						end
				  elsif prot==3
						unless ts2.nil? then
						  ts2.update_attributes(:matrix => attribut[0], :source_id=>attribut[1])
						  log.write("BD-QTS TS_update 4" + attribut[2].to_s + "\n")
						end
				  else
						unless ts2.nil? then
						  ts2.update_attributes(:source_id=>attribut[1])
						  log.write("BD-QTS TS_update 4" + attribut[2].to_s + "\n")
						end
				  end
				elsif (defi[1]=="STN") then
			  	log.write("BD-STN " + defi[2].to_i.to_s + " searching\n")
			  	if (!b.nil? and b.intnummer!=defi[2].to_i) then
						b = Bediengeraet.getBediengeraet(defi[2].to_i, system_id)
						log.write("BD-STN " + defi[2].to_i.to_s + " found\n")
			  	end
			  	#if (!tt.nil? and tt.bediengeraet_id!=b.id and tt.tasten_id!=defi[3].to_i) then
					tt = Typetarget.find_by_bediengeraet_id_and_tasten_id(b.id, defi[3].to_i)
			  	#end
			  	prot = b.bdtype_id
			  	if prot==3 then
						unless tt.nil? then
				  		tt.update_attributes(:matrix => attribut[0], :target_id=>attribut[1])
						end
			  	elsif prot==6 then
						unless tt.nil? then
					  	tt.update_attributes(:target_id=>attribut[1])
						end
				  elsif prot==5 then
						unless tt.nil? then
						  tt.update_attributes(:target_id=>attribut[1])
						end
				  end
				end

		  # KV_I
		  # ;Salov Konfiguration KV_S_SalnoNr=Futureuse1,RowNr,Matrix,Senke,Quelle,Futureuse2_char3,Futureuse3
		  # KV_S_001=01,003,01,003,003,"   ",001
		  elsif defi[0]=="KV" then
			if defi[1]=="SS" then
				# KV_SS_001="demo1     "
				@salvo = Salvo.new(:intnummer => defi[2].to_i ,:name => tupel[1].strip ,:system_id => system_id)
				@salvo.save
				c=0
				128.times {
					c=c+1
					Crosspoint.new(:nummer=>c, :kreuzschiene_id=>nil, :salvo_id => @salvo.intnummer, :source_id=>nil, :target_id=>nil, :system_id=>system_id, :comment => '', :parameter => '', :value => '', :source_single_class => '', :source_subclass => '', :source_component => '', :source_subcomponent => '', :dest_single_class => '', :dest_subclass => '', :dest_component => '', :dest_subcomponent => '').save
				}
			elsif defi[1]=="S" then
				attribut = tupel[1].split(",")
				setup = Crosspoint.find_by_system_id_and_nummer_and_salvo_id(system_id, attribut[1].to_i, defi[2].to_i)
				kid = Kreuzschiene.find_by_system_id_and_intnummer(system_id, attribut[2].to_i)
				source = Source.find_by_kreuzschiene_id_and_intnummer(kid.id, attribut[4].to_i)
				target = Target.find_by_kreuzschiene_id_and_intnummer(kid.id, attribut[3].to_i)
				@salvo  = Salvo.find_by_intnummer_and_system_id(defi[2].to_i, system_id)
				@salvo.update_attributes(:salvo_type => attribut[0])
				unless setup.nil? then
					if attribut[0][-1,1].to_i==0
						setup.update_attributes(:kreuzschiene_id=>kid.id, :target_id=>target.id, :source_id=>source.id)
					elsif attribut[0][-1,1].to_i==1
						data = attribut[5].split('.');
						#stack = data[0].to_s+"."+(data[1].to_i).to_s
						frame = data[2]
						slot = data[3]
						setup.update_attributes(:stack1 => data[0].to_s,:stack2 => data[1].to_s, :frame => frame, :slot => slot, :parameter => attribut[13], :value => attribut[14], :comment => attribut[15])

					elsif attribut[0][-1,1].to_i==2
						setup.update_attributes(:source_single_class => attribut[5], :source_subclass => attribut[6].to_i, :source_component => attribut[7].to_i, :source_subcomponent => attribut[8].to_i,:dest_single_class => attribut[9],:dest_subclass => attribut[10].to_i,:dest_component => attribut[11].to_i,:dest_subcomponent => attribut[12].to_i,:parameter => '', :value => '', :comment => '')
					end
				end

			elsif defi[1]=="I" then

			  k = Kreuzschiene.find_by_system_id_and_intnummer(system_id, defi[2].to_i)
			  #opt = @vs_nr.value.to_i

			  attribut = tupel[1].split(",")

			  s = Source.find_by_kreuzschiene_id_and_intnummer(k.id,defi[3].to_i)
			  unless s.nil? then

				attribut[0].nil? ? n5s = "" : n5s = attribut[0].strip
				attribut[1].nil? ? n4s = "" : n4s = attribut[1].strip
				attribut[2].nil? ? ch6 = "" : ch6 = attribut[2].strip
				attribut[3].nil? ? ch10 = "" : ch10 = attribut[3].strip

				if k.kr_type == "MATRIX" && !k.matrix_type.nil? && k.matrix_type.title == "Lawo MONPL"
					attribut[4].strip == "000" ? tb = "" : tb = attribut[4].strip.to_i
					if !attribut[5].nil? && !attribut[6].nil?
						mtx = attribut[5].strip.to_i
					else
						mtx = ""
					end
					attribut[6].strip == "00" ? ql = "" : ql = attribut[6].strip.to_i
					attribut[7].nil? ? cm = "" : cm = attribut[7].strip
					hexa = "0x"+sprintf("%0x",attribut[8].strip.to_i).to_s
					if SignalQuellen.exists?(["hexa = ?",hexa])
						signal = SignalQuellen.find_by_hexa(hexa).intnummer
					else
						signal = nil
					end
					s.update_attributes(:name5stellig => n5s.strip, :name4stellig => n4s.strip, :char6 => ch6.strip, :char10 => ch10.strip, :tallybit => tb.to_s, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => cm.strip, :signal => signal, :subclass => attribut[9].strip.to_i, :component => attribut[10].strip.to_i, :subcomponent => attribut[11].strip.to_i, :family_id =>(attribut[12].nil? ? 0:attribut[12]))

				elsif k.kr_type == "MATRIX" && !k.matrix_type.nil? && k.matrix_type.title == "Stagetec"
					if !attribut[4].nil?
						attribut[4].strip == "000" ? tb = "" : tb = attribut[4].strip.to_i
					else
						tb = ""
					end
					if !attribut[5].nil? && !attribut[6].nil?
						mtx = attribut[5].strip.to_i
					else
						mtx = ""
					end
					if !attribut[6].nil?
						attribut[6].strip == "00" ? ql = "" : ql = attribut[6].strip.to_i
					else
						ql = ""
					end
					attribut[7].nil? ? cm = "" : cm = attribut[7].strip
					attribut[9].nil? ? real_input = "" : real_input = attribut[9].strip

					s.update_attributes(:name5stellig => n5s.strip, :name4stellig => n4s.strip, :char6 => ch6.strip, :char10 => ch10.strip, :tallybit => tb.to_s, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => cm.strip, :real_input => real_input, :family_id => !attribut[10].nil? ? attribut[10].strip.to_i : 0)
				elsif k.kr_type == "MIXER"
					attribut[4].strip == "000" ? tb = "" : tb = attribut[4].strip.to_i
					!attribut[5].nil? && !attribut[6].nil? ? mtx = attribut[5].strip.to_i : mtx = ""
					attribut[6].strip == "00" ? ql = "" : ql = attribut[6].strip.to_i
					attribut[7].nil? ? cm = "" : cm = attribut[7].strip

					s.update_attributes(:name5stellig => n5s.strip, :name4stellig => n4s.strip, :char6 => ch6.strip, :char10 => ch10.strip, :tallybit => tb.to_s, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => cm.strip, :channel => attribut[8].to_i, :family_id => ( (!attribut[9].nil?) ? attribut[9].strip.to_i : 0), :par_matrix => (( !attribut[10].nil? && (attribut[10].to_i != 0) ) ? attribut[10].strip.to_i : nil), :par_quelle => ( ( !attribut[11].nil? && (attribut[11].to_i != 0) ) ? attribut[11].strip.to_i : nil ) )
				else


					if attribut.size < 6
						attribut[4].nil? ? cm = "" : cm = attribut[4].strip

						s.update_attributes(:name5stellig => n5s.strip, :name4stellig => n4s.strip, :char6 => n5s.strip, :char10 => n5s.strip, :comment => n5s.strip, :family_id => (!attribut[attribut.length - 1].nil? ? attribut[attribut.length - 1].strip.to_i : 0))
					else

						attribut[4].strip == "000" ? tb = "" : tb = attribut[4].strip.to_i
						!attribut[5].nil? && !attribut[6].nil? ? mtx = attribut[5].strip.to_i : mtx = ""
						attribut[6].strip == "00" ? ql = "" : ql = attribut[6].strip.to_i
						attribut[7].nil? ? cm = "" : cm = attribut[7].strip

						s.update_attributes(:name5stellig => !n5s.nil? ? n5s.strip : "", :name4stellig => !n4s.nil? ? n4s.strip : "", :char6 => !ch6.nil? ? ch6.strip : "", :char10 => !ch10.nil? ? ch10.strip : "", :tallybit => tb.to_s, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => !cm.nil? ? cm.strip : "", :channel => attribut[8].to_i, :family_id => !attribut[9].nil? ? attribut[9].strip.to_i : 0,:green => attribut[10].to_i != 0 ? attribut[10].strip.to_i : 0, :yellow => attribut[11].to_i != 0 ? attribut[11].strip.to_i : 0, :blue => attribut[12].to_i != 0 ? attribut[12].strip.to_i : 0)
					end
				end

			  end

			# KV_O
			elsif defi[1]=="O" then

			  k = Kreuzschiene.find_by_system_id_and_intnummer(system_id, defi[2].to_i)
			  #opt = @vs_nr.value.to_i

			  attribut = tupel[1].split(",")
			  t = Target.find_by_kreuzschiene_id_and_intnummer(k.id,defi[3].to_i)

			  unless t.nil? then
				attribut[0].nil? ? n5s = "" : n5s = attribut[0].strip
				attribut[1].nil? ? n4s = "" : n4s = attribut[1].strip
				attribut[2].nil? ? ch6 = "" : ch6 = attribut[2].strip
				attribut[3].nil? ? ch10 = "" : ch10 = attribut[3].strip

				if k.kr_type == "MATRIX" && !k.matrix_type.nil? && k.matrix_type.title == "Lawo MONPL"
					mtx = attribut[4].strip.to_i
					attribut[5].strip == "00" ? ql = "" : ql = attribut[5].strip.to_i
					attribut[6].nil? ? cm = "" : cm = attribut[6].strip
					hexa = "0x"+sprintf("%0x",attribut[7].strip.to_i).to_s
					if SignalQuellen.exists?(["hexa = ?",hexa])
						signal = SignalSenken.find_by_hexa(hexa).intnummer
					else
						signal = nil


					end

					t.update_attributes(:name5stellig=>n5s.strip, :name4stellig=>n4s.strip, :char6 => ch6.strip, :char10 => ch10.strip, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => cm.strip, :signal => attribut[7].strip.to_i, :subclass => attribut[8].strip.to_i, :component => attribut[9].strip.to_i, :subcomponent => attribut[10].strip.to_i, :family_id => (!attribut[attribut.length - 2].nil? ? attribut[attribut.length - 2].strip.to_i : 0))
				elsif k.kr_type == "MATRIX" && !k.matrix_type.nil? && k.matrix_type.title == "Stagetec"
					if !attribut[4].nil?
						mtx = attribut[4].strip.to_i
					else
						mtx = ""
					end
					if !attribut[5].nil?
						attribut[5].strip == "00" ? ql = "" : ql = attribut[5].strip.to_i
					else
						ql = ""
					end
					attribut[6].nil? ? cm = "" : cm = attribut[6].strip
					attribut[8].nil? ? real_output = "" : real_output = attribut[8].strip

					t.update_attributes(:name5stellig=>n5s.strip, :name4stellig=>n4s.strip, :char6 => ch6.strip, :char10 => ch10.strip, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => cm.strip, :real_output => real_output, :family_id => (!attribut[attribut.length - 1].nil? ? attribut[attribut.length - 1].strip.to_i : 0) )
				else
					if attribut.size < 6
						attribut[4].nil? ? cm = "" : cm = attribut[4].strip

						t.update_attributes(:name5stellig=>n5s.strip, :name4stellig=>n4s.strip, :char6 => n5s.strip, :char10 => n5s.strip, :comment => n5s.strip, :family_id => (!attribut[attribut.length - 1].nil? ? attribut[attribut.length - 1].strip.to_i : 0) )
					else
						mtx = attribut[4].strip.to_i
						attribut[5].strip == "00" ? ql = "" : ql = attribut[5].strip.to_i
						attribut[6].nil? ? cm = "" : cm = attribut[6].strip
						t.update_attributes(:name5stellig=>n5s.strip, :name4stellig=>n4s.strip, :char6 => ch6.strip, :char10 => ch10.strip, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => cm.strip, :channel => attribut[7].to_i,:family_id => (!attribut[8].nil? ? attribut[8].strip.to_i : 0), :red => (!attribut[9].nil? ? attribut[9].strip.to_i : 0), :green => (!attribut[10].nil? ? attribut[10].strip.to_i : 0), :yellow => (!attribut[11].nil? ? attribut[11].strip.to_i : 0), :blue => (!attribut[12].nil? ? attribut[12].strip.to_i : 0) )
					end
				end
			  end

			elsif defi[1]=="REE" then
			# KV_REE_QUELLE=00,005,01,001
			# KV_REE_SENKE=00,030,01,001,004
			# KV_REE_SENKE=01,001,00,001

				attribut = tupel[1].split(",")
				k = Kreuzschiene.find_by_system_id_and_intnummer(system_id, attribut[0].to_i)
				if defi[2]=="QUELLE" then
					s = Source.find_by_kreuzschiene_id_and_intnummer(k.id, attribut[1].to_i)
					s.update_attributes(:mx_matrix => attribut[2].to_i, :mx_senke => attribut[3].to_i, :enable => attribut[4].to_i)
				elsif defi[2]=="SENKE" then
					if attribut.size == 4
						t = Target.find_by_kreuzschiene_id_and_intnummer(k.id, attribut[1].to_i)
						t.update_attributes(:mx_matrix => attribut[2].to_i, :mx_quelle => attribut[3].to_i)
					else
						t = Target.find_by_kreuzschiene_id_and_intnummer(k.id, attribut[4].to_i)
						t.update_attributes(:mx_tallybit => attribut[1].to_i, :mx_matrix => attribut[2].to_i, :mx_quelle => attribut[3].to_i)
					end
				end

			end

		  # Clon_tally
		  elsif defi[0]=="CLON" then
			if defi[1]=="TALLY" then
				attribut = tupel[1].split(",")
				k = Kreuzschiene.find_by_system_id_and_intnummer(system_id, attribut[0].to_i)
				s = Source.find_by_kreuzschiene_id_and_intnummer(k.id, attribut[1].to_i)
				unless s.nil? then
					attribut[2].to_i == 0 ? cl = nil : cl = attribut[2].to_i
					s.update_attributes(:cloneinput => "#{cl}")
				end
			end

		  # Frames
		  elsif defi[0]=="MI" and defi[1]=="T" then
			bme = Bme.find_by_taste_and_system_id(defi[3].to_i, system_id)
			unless bme.nil? then
			  bme.update_attributes(:source_id=>tupel[1])
			end

		  # UMD DEV KV                                SYSTEM-AWARE
		  elsif defi[0]=="UMD" then
			if defi[1]=="DEF" then
				attribut = tupel[1].split(",")
				u = Umd.find_by_intnummer_and_system_id(defi[3].to_i, system_id)

				if defi[2]=="KV" then
				  unless u.nil? then
					kv = Kreuzschiene.find_by_intnummer_and_system_id(attribut[0], system_id)
					u.update_attributes(:kreuzschiene_id=>kv.id, :target_id=>attribut[1], :choice => attribut[3].nil? ? nil : attribut[3][-1,1])
				  end

				elsif defi[2]=="TXT" then
				  unless u.nil? then
					u.update_attributes(:festtext=>attribut[0].strip)
				  end

				elsif defi[2]=="MON" then
				  unless u.nil? then
					u.update_attributes(:monitor=>attribut[0], :gpi=>attribut[2])
				  end




				elsif defi[2]=="HAV" then
				  unless u.nil? then
					u.update_attributes(:bme=>attribut[0])
				  end

				elsif defi[2]=="KVH" then
				  unless u.nil? then
					u.update_attributes(:mon_havarie=>attribut[0])
				  end

				elsif defi[2]=="CON" then
				  unless u.nil? then
					u.update_attributes(:konfiguration=>attribut[0])
				  end
				elsif defi[2]=="CHOICE" then
				  unless u.nil? then
					#u.update_attributes(:choice=>attribut[0][-1,1], :type_option=>attribut[1][-1,1],:ip_address =>attribut[2].strip,:panel=>attribut[3],:vts_input=>attribut[4])
					u.update_attributes(:type_option=>attribut[1][-1,1],:ip_address =>attribut[2].strip,:panel=>attribut[3],:vts_input=>attribut[4])
				  end
				end
			elsif defi[1]=="PGM" then
			  u = Umd.find_by_intnummer_and_system_id(tupel[1].to_i, system_id)
			  u.update_attributes(:pgm_monitor => "1")
			end

			# SENDE_BD = panel_id, matrix_id, senke_id
		elsif defi[0]=="SENDE" then
			if defi[1]=="BD" then
				attribut = tupel[1].split(",")
				p = Bediengeraet.find_by_system_id_and_intnummer(system_id, attribut[0].to_i)
				unless p.nil? then
				  p.update_attributes(:sende_matrix_id => attribut[1].to_i, :sende_senke_id => attribut[2].to_i)
				end
			end

			  # MIX_TAST= intnummer, senke of kv1
		elsif defi[0]=="MIX" then
			attribut = tupel[1].split(",")
			b = Bme.find_by_taste_and_system_id(attribut[0].to_i, system_id)
			b.update_attributes(:peview_monitor => attribut[1].to_i)
		elsif defi[0]=="SYSCOL" then
			attribut = tupel[1].split(",")
			SystemColor.create(:nummer => defi[1], :red => attribut[0].to_i*2,:green=> attribut[1].to_i*2, :blue=>attribut[2].to_i*2, :name => attribut[3])
		elsif defi[0]=="FAMILY" then
			attribut = tupel[1].split(",")
			Family.create(:nummer => defi[1], :system_color_id => attribut[0],:name=> attribut[1], :position => defi[1])
		elsif defi[0]=="MATCHING"
			attribut = tupel[1].split(",")
			count = SystemMatching.count(:conditions => ["system_id = ?",system_id])
			if count==0
				nummer = 1
			else
				nummer = count+1
			end
			SystemMatching.create(:system_id => system_id, :intnummer => nummer, :matching_panel => attribut[0], :matching_set => defi[1], :matching_start_quelle => attribut[1], :matching_end_quelle => attribut[2], :matching_matrix => attribut[3], :matching_senke => attribut[4])
		elsif defi[0]=="COLLECT" && defi[1]=="FAMILY" && defi[2]=="FONT"
		  attribut = tupel[1].split(",").map{|x| x.to_i}
      	label = Option.find_or_create_by_title("family_label")
      	label.update_attribute('value', attribut[0])
    		font = Option.find_or_create_by_title("family_font")
    		font.update_attribute('value', attribut[1])

		elsif defi[0]=="ASSOZIATION"
			attribut = tupel[1].split(",")
			SystemAssoziation.create(:system_id => system_id, :intnummer => defi[2], :source_matrix => attribut[0], :source_senke => attribut[1], :matrix_1 => attribut[2], :senke_1 => attribut[3], :matrix_2 => attribut[4], :senke_2 => attribut[5], :matrix_3 => attribut[6], :senke_3 => attribut[7])
		end
		end
        end
      end # transaction
      end

    flash[:notice]="Version " + currsystem.version.to_s + " wurde mit " + zeile.to_s + " Zeilen von <b>" + datasource.to_s + "</b> in den Konfigurationsspeicher " + system_id.to_s + " eingelesen"
    log.write("Version " + currsystem.version.to_s + " wurde mit " + zeile.to_s + " Zeilen von <b>" + datasource.to_s + "</b> in den Konfigurationsspeicher " + system_id.to_s + " eingelesen")
    log.close


    # => GPIO Section
    #if File.exist?("#{RAILS_ROOT}/conf/#{system_id}/gpio.conf")
    if File.exist?("#{RAILS_ROOT}/conf/gpio.conf")
        log = File.open("#{RAILS_ROOT}/log/import_gpio_log.txt", 'w')
        log.write("----==============----\n")
        log.write("System " + currsystem.id.to_s + "\n")

        gpio = File.open("#{RAILS_ROOT}/conf/gpio.conf", 'r')

        GpInput.clear_system_values(system_id)
        GpOutput.clear_system_values(system_id)
        gpio.each do |line|
            if line.match(/^DEF_GPIO_IN_\d/)
                formatted_line = line.split("DEF_GPIO_IN_")
                formatted_line.shift
                values = formatted_line[0].split("=")
                if values[0].to_i == 1
                    input_value = 1001
                else
                    input_value = GpInput.find_by_intnummer(values[0].to_i - 1).value + 1
                end
                field_values = values[1].split(",").map{|x| x.gsub('"','')}.map{|x| x.strip}
                log.write("#{field_values.inspect}\n")
#                DEF_GPIO_IN_NrofInput="16charName      ",Type,Unit/Panel,Port,Byte,Bit,Invert,RadioButton Group,"16charComment   "
                input = GpInput.new({:intnummer => values[0].to_i,
                                     :name => field_values[0],
                                     :system_id => system_id,

                                     :i_type => field_values[1].to_i,
                                     :unit => field_values[2].to_i,
                                     :port => field_values[3].to_i,
                                     :byte => field_values[4].to_i,
                                     :bit => field_values[5].to_i,
                                     :invert => field_values[6].to_i,
                                     :radio => field_values[7].to_i,
                                     :comment => field_values[8],
                                     :value => input_value
                                     }).save
            end

            if line.match(/^DEF_GPIO_OUT_\d/)
                formatted_line = line.split("DEF_GPIO_OUT_")
                formatted_line.shift
                values = formatted_line[0].split("=")
                field_values = values[1].split(",").map{|x| x.gsub('"','')}.map{|x| x.strip}
                if values[0].to_i == 1
                    input_value = 2001
                else
                    input_value = GpOutput.find_by_intnummer(values[0].to_i - 1).value + 1
                end
#               DEF_GPIO_OUT_Nrofoutput="16char Name     ","16cha ActiveName",16cha Inact Name",Mode,Type,Unit/Panel,Port,Byte,Bit,Invert,Comment
                input = GpOutput.new({:intnummer => values[0].to_i,
                                     :name => field_values[0],
                                     :system_id => system_id,
                                     :active_name => field_values[1],
                                     :inactive_name => field_values[2],
                                     :mode => field_values[3].to_i,
                                     :o_type => field_values[4].to_i,
                                     :unit => field_values[5].to_i,
                                     :port => field_values[6].to_i,
                                     :byte => field_values[7].to_i,
                                     :bit => field_values[8].to_i,
                                     :invert => field_values[9].to_i,
                                     :comment => field_values[10],
                                     :value => input_value
                                     }).save
            end
        end

	f_new_conf = File.new("#{RAILS_ROOT}/conf/#{@system.id}/gpio.conf","w")

	File.open("#{RAILS_ROOT}/conf/gpio.conf", 'r').each do |e|
		f_new_conf.write(e)
	end

	f_new_txt = File.new("#{RAILS_ROOT}/conf/#{@system.id}/gpio.txt","w")

	File.open("#{RAILS_ROOT}/conf/gpio.txt", 'r').each do |e|
		f_new_txt.write(e)
	end
    end

    respond_to do |format|
      format.html { redirect_to :action => "show", :id=>system_id }
    end

	@content = Option.getIbtContent
	@content.update_attributes(:value => ibt_content)

  end

  def system_color
	@system_id = cookies[:system_id]
	@system_colors = SystemColor.find(:all)
	if request.post?
		@system_color = SystemColor.find(params[:id])
		@system_color.update_attributes(params[:system_color])
		redirect_to :action => 'system_color'
	end
  end

  def create_system_color

	if request.post?
		@system_color = SystemColor.new(params[:system_color])
		if @system_color.save
			redirect_to :action => "system_color"
		end
	end
  end

  def delete_system_color
	if SystemColor.find(params[:id]).destroy()
		flash[:notice] = "System color deleted successfully"
		redirect_to :action => "system_color"
	end
  end

  def backup_unit
      if params[:id]
         require 'Multi_FTP'
         require 'timeout'
         require 'net/ssh'

         f = File.open("#{RAILS_ROOT}/log/backup_unit.log", 'r+')
         f.readlines
         system_id = params[:id]
         ftpdest = ""
         @system = System.find(system_id)
         f.write("=============#{Time.now}=============\n")
         @system.frames.each_with_index do |frame,index|

            if frame.ipadresse.size > 0 then
               veto = 0
               f.write(">>FTP: " + frame.ipadresse + " " + Global::FTPUSER + " " + Global::FTPPASSWD + "\n")
               ftp = nil

               begin
                  timeout(Global::CON_TIMEOUT) do
                     f.write(">>FTP: trying to connect #{frame.ipadresse}")
		     ftp = Multi_FTP.new()
                     if request.remote_ip.to_s == "192.168.33.174"
			 ftp.setup("hb","hbdev","192.168.33.157")
                     else
                         ftp.setup("#{Global::FTPUSER}","#{Global::FTPPASSWD}",frame.ipadresse)
                     end
                  end
                  f.write(">>FTP connect successfully " + frame.ipadresse + "\n")
               rescue Net::SSH::AuthenticationFailed => msg
                  ftpdest = ftpdest + "<font color='red'>Fehler Login: " + frame.ipadresse + "</font><br />"
                  f.write(">>FTP error connect \n")
                  veto = 1
                  GC.start
                  sleep Global::CLOSE_TIMEOUT
               rescue Timeout::Error => msg
                  ftpdest = ftpdest + "<font color='red'>Fehler Timeout: " + frame.ipadresse + "</font><br />"
                  f.write(">>FTP error connect \n")
                  veto = 1
                  GC.start
                  sleep Global::CLOSE_TIMEOUT
               end

               unless veto==1 then
                  begin
                     timeout(Global::TRANSFER_TIMEOUT) do
                        f.write(">>FTP: trying to transfer (get)\n")
                        num = index+1
                    	  if !File.directory?("#{RAILS_ROOT}/conf/hardware_bak")
				Dir.mkdir("#{RAILS_ROOT}/conf/hardware_bak")
				f.write(">>FTP: Created 'hardware_bak' folder\n")
			  end
                    	  if !File.directory?("#{RAILS_ROOT}/conf/hardware_bak/Unit_#{sprintf("%02d",num)}")
		                Dir.mkdir("#{RAILS_ROOT}/conf/hardware_bak/Unit_#{sprintf("%02d",num)}")
		                f.write(">>FTP: Created Unit_#{sprintf("%02d",num)} folder\n")
			  end
                    	  if !File.directory?("#{RAILS_ROOT}/conf/hardware_bak/Unit_#{sprintf("%02d",num)}/hd")
		                Dir.mkdir("#{RAILS_ROOT}/conf/hardware_bak/Unit_#{sprintf("%02d",num)}/hd")
		                f.write(">>FTP: Created hd folder\n")
			  end
                        num = index+1
			ftp.go_get("#{RAILS_ROOT}/conf/hardware_bak/Unit_#{sprintf("%02d",num)}/hd/","#{Global::FTPDIR}/")
                        f.write(">>FTP: Downloaded Unit_#{sprintf("%02d",num)}/hd folder\n")
                     end
                     f.write(">>FTP: done for " + frame.ipadresse + "\n")
                     ftpdest = ftpdest + "<font color='green'><b>Übertragung nach " + frame.ipadresse + " erfolgreich</b></font><br />"
                  rescue Timeout::Error => msg
                     f.write(">>FTP error " + msg + "\n")
                     ftpdest = ftpdest + "<font color='red'>Fehler1 Übertragung nach " + frame.ipadresse + "<br />" + "</font>"
                  rescue Exception => e
                     f.write(">>FTP error " + [e.message,e.application_backtrace].to_s + "\n")
                     ftpdest = ftpdest + "<font color='red'>Fehler2 Übertragung nach " + frame.ipadresse + "<br />" + "</font>"
                  ensure
                     #ftp.close!(test_def) if ftp
                     GC.start
                     sleep Global::CLOSE_TIMEOUT
                  end
               end
            end
         end

         flash[:notice] = ftpdest
         redirect_to :action => "show", :id=>system_id
      end
  end

  def restore_unit
   if params[:id]
      require 'Multi_FTP'
      require 'net/ftp'
      require 'timeout'

      ftpdest = ''
      system_id = cookies[:system_id]
      @system = System.find(system_id)

      @system.frames.each_with_index do |frame,index|
         if frame.ipadresse.size > 0 then
            veto = 0
            logger.info(">>FTP: " + frame.ipadresse + " " + Global::FTPUSER + " " + Global::FTPPASSWD)
            ftp = nil

            begin
               timeout(Global::CON_TIMEOUT) do
                  logger.info(">>FTP: trying to connect #{frame.ipadresse}")
                  #ftp = Net::FTP::new(frame.ipadresse)
                  ftp = Multi_FTP.new()

                  #ftp.setup("hb", "hbdev","192.168.33.157")
                  ftp.setup("#{Global::FTPUSER}","#{Global::FTPPASSWD}",frame.ipadresse)
               end
               logger.info(">>FTP connect successfully " + frame.ipadresse)
            rescue Net::FTPPermError => msg
               ftpdest = ftpdest + "<font color='red'>Fehler Login: " + frame.ipadresse + "</font><br />"
               logger.info(">>FTP error connect ")
               veto = 1
               GC.start
               sleep Global::CLOSE_TIMEOUT
            rescue Timeout::Error => msg
               ftpdest = ftpdest + "<font color='red'>Fehler Timeout: " + frame.ipadresse + "</font><br />"
               logger.info(">>FTP error connect ")
               veto = 1
               GC.start
               sleep Global::CLOSE_TIMEOUT
            end
            # Bei Verbindung Daten holen versuchen
            ftpdest = ""
            unless veto==1 then
               begin
                  timeout(Global::TRANSFER_TIMEOUT) do
                        num = index+1
                        #send_it(ftp,Global::FTPDIR,"#{RAILS_ROOT}/conf/hardware_bak/Unit_#{sprintf("%02d",num)}/hd")
                        ftp.go_send("#{RAILS_ROOT}/conf/hardware_bak/Unit_#{sprintf("%02d",num)}/hd/","#{Global::FTPDIR}/")
                  end
                  logger.info(">>FTP: done for " + frame.ipadresse)
                  ftpdest = ftpdest + "<font color='green'><b>Übertragung nach " + frame.ipadresse + " erfolgreich</b></font><br />"
               rescue Timeout::Error => msg
                  logger.info(">>FTP error " + msg)
                  ftpdest = ftpdest + "<font color='red'>Fehler1 Übertragung nach " + frame.ipadresse + "<br />" + "</font>"
               rescue Exception => e
                  render :text => [e.message,e.application_backtrace].inspect and return false

                  ftpdest = ftpdest + "<font color='red'>Fehler2 Übertragung nach " + frame.ipadresse + "<br />" + "</font>"
               ensure
                  #ftp.close if ftp
                  GC.start
                  sleep Global::CLOSE_TIMEOUT
               end
            end
         end
      end
      flash[:notice] = ftpdest
      redirect_to :action => "show", :id=>system_id

   end
  end

   def send_it(ftp,remote,local)
      #open local and remote directories
      Dir.chdir(local)
      ftp.chdir(remote)

      #make a local copy of file list to reduce network calls
      remote_list = ftp.nlst()
      Dir.entries(".").each { |thefile|

         #be sure not to try and send the current and parent directory
         if thefile != "." and thefile != ".."
            filename = File.basename(thefile)

            #check if this is a file
            if not File.directory?(thefile)
               ftp.putbinaryfile(thefile,thefile)
            else
               if not remote_list.index(filename)
                  ftp.mkdir(filename)
               end

               #make recursive call
               send_it(ftp,filename,filename)

               #move back up to parent directory after sending directory
               ftp.chdir("..")
               Dir.chdir("..")
            end
         end
      }
   end

  def firmware_update_unit
    if params[:id]
      system_id = params[:id]
      @system = System.find(system_id)
      @system.frames.each do |frame|
        if frame.ipadresse.size > 0 then
            res = `cd #{RAILS_ROOT}/../../../Service/Firmware_Update_Batches && Firmware_update_all.bat #{frame.ipadresse}`
        end
      end
    end
      flash[:notice] = "Firmware Update completed successfully."
      redirect_to :action => "show", :id=>system_id
  end

	def software_update
		if request.post?
			@upload_file_name = params['latest_code'].original_filename
			@upload_file_type = params['latest_code'].content_type

			if File.exist?("#{RAILS_ROOT}/public/files/#{@upload_file_name}")
			  FileUtils.rm_rf("#{RAILS_ROOT}/public/files/#{@upload_file_name}")
			end

			File.open("#{RAILS_ROOT}/public/files/#{@upload_file_name}", "wb") do |f|
				f.write(params['latest_code'].read)
			end

			time_stamp = DateTime.now.strftime("%d-%m-%Y")
			parent_path = Pathname.new(RAILS_ROOT).parent.realpath.to_s
			rails_root = parent_path + "/config"
			cp_path = parent_path + "/#{time_stamp}_config"

			dirs_to_del = Dir[RAILS_ROOT + "/../*"].select {|f| test ?d, f}.sort_by {|f| File.mtime f}.map!{|x| File.basename(x)}.select{|x| x if (x =~ /config/) == 11}

			dirs_to_del.each do |x|
				FileUtils.rm_rf Dir.glob(parent_path+ "/" + x +"/*")
				FileUtils.rm_rf Dir.glob(parent_path+ "/" + x )
			end


			FileUtils.cp_r rails_root, cp_path
			zip_source = "#{cp_path}/public/files/#{@upload_file_name}"

			FileUtils.rm_rf Dir.glob(rails_root+ "/*")

			unzip_file(zip_source, parent_path)
			@systems = System.find(:all)
			@systems.each do |system|
				@system = system
				@system.write
				if !File.directory?("#{RAILS_ROOT}/conf/#{@system.id}")
					  Dir.mkdir("#{RAILS_ROOT}/conf/#{@system.id}")
				end
				FileUtils.cp "#{RAILS_ROOT}/conf/ibt.conf","#{RAILS_ROOT}/conf/#{@system.id}/ibt.conf"
				File.open( "conf/#{@system.id}/gpio.txt", "w" ) do |f|
				# TODO Do write something here
				end

				File.open( "conf/#{@system.id}/gpio.conf", "w" ) do |f|
				# TODO Do write something here.
				end
			end

			`mysqldump -u root config > #{RAILS_ROOT}/db/old_sql/config.sql`

			puts "Extraction completed..."
			puts "Updating Db..."

			`mysql -u root config < #{RAILS_ROOT}/db/sql/config_1.sql`
			`mysql -u root config < #{RAILS_ROOT}/db/sql/config_2.sql`
			render :action => "restart"
		end
	end

	def reimport_all_configuration
			@systems = System.find(:all)
			@systems.each do |system|
				@system = system
				FileUtils.cp "#{RAILS_ROOT}/conf/#{@system.id}/ibt.conf","#{RAILS_ROOT}/conf/ibt.conf"
				import_backup(@system.id)
			end
			flash[:notice] = "All configurations updated successfully"
			redirect_to :action => "index"
	end

	def restart_system
        #"shutdown.exe -r -f -t 0"
        #test = "#{ENV['SystemRoot'] + '\system32\shutdown.exe /?'}"
        #os    = WMI::Win32_OperatingSystem.find(:first)
        os = WMI::Win32_OperatingSystem.find( :first, :privileges =>[WMI::Privilege::Shutdown] )
        os.win32shutdown(2)
        #"shutdown.exe"
	end

	def unzip_file (file, destination)
		Zip::ZipFile.open(file) { |zip_file|
			zip_file.each { |f|
			f_path=File.join(destination, f.name)
			FileUtils.mkdir_p(File.dirname(f_path))
			zip_file.extract(f, f_path) unless File.exist?(f_path)
			}
		}
	end

	def import_backup(id)
		system_id = id
		@vs_nr = Option.getIbtVersionOption
		begin
			currsystem = System.find(system_id)
		rescue
			currsystem = System.create(:name=>"System " + system_id.to_s, :version=>1)
			currsystem.save
		end

		log = File.open("#{RAILS_ROOT}/log/import_log.txt", 'w')

		currsystem.build_clean_configuration("")

		log.write("----==============----\n")
		log.write("System " + currsystem.id.to_s + "\n")

		msg = ""
		zeile = 0
		ibt_content = ""

		f = File.open("#{RAILS_ROOT}/conf/ibt.conf", 'r')

		# durchgeschlurtes BG
		b = Bediengeraet.new
		ts1 = Typesource.new
		ts2 = Typesource.new
		SystemColor.destroy_all
		Family.destroy_all
		SystemMatching.delete_all("system_id = #{system_id}")
		SystemAssoziation.delete_all("system_id = #{system_id}")
		tt = Typetarget.new

		System.transaction do
		#begin
		  f.each do |line_complete|

				line_complete.split(/\r/).each do |line|
				if zeile==0 then
				  currsystem.update_attribute(:version, line)
				end
				zeile = zeile + 1
				log.write(zeile.to_s + " >> " + line.to_s + "\n")

				if !line.nil? and line.strip == "DEMOSYSTEM"
					s_matrix = Option.getSimulateMatrix
					s_matrix.update_attributes(:value => "true")
				end

				if !line.nil? and line.strip.length>5 and line[0]!=";" then
				  tupel = line.delete('"').strip.split("=")
				  defi = tupel[0].split("_")

				  if line.to_s.slice(0, 4) == "GUI_"
						ibt_content << line.strip.slice(4..-1).to_s << "\n"
				  end

				  ### Tally section ReadBack ###
				  if Global::READBACKTALLY.include? tupel[0].strip
						attribut = tupel[1].split(",")

						if tupel[0].strip == "KV_HAV_TALLY"
						  tally_name = "RED_TALLY"
						else
						  tally_name = tupel[0].strip
						end

						tl = Tally.find_by_name_and_system_id(tally_name, system_id)
						tl.update_attributes(:kreuzschiene_id => attribut[0].to_i, :senke_id => attribut[1].to_i )
		  		end

	  			if tupel[0].strip == "TSL_TEXTE"
						mv = Option.getMultiViewer
						mv.update_attributes(:value => tupel[1].strip)
		  		end

				  ########

				  ###### UN_DEF
				  ## Frames                                      (SYSTEM-AWARE!)
				  if defi[0]=="UN" and defi[1]=="DEF" then

						attribut = tupel[1].split(",")
						f = Frame.find_by_intnummer_and_system_id(defi[2].to_i, system_id)
						unless f.nil? then
							f.update_attributes(:name=>'UNIT ' + attribut[0].to_s, :ipadresse=>attribut[1])
						end

				  # Kreuzschienen                               (SYSTEM-AWARE!)
				  elsif defi[0]=="KV" and defi[1]=="DEF" then

						attribut = tupel[1].split(",")
						k = Kreuzschiene.find_by_intnummer_and_system_id(defi[2].to_i, system_id)

						unless k.nil? then
							Source.destroy_all(:kreuzschiene_id=>k)
							Target.destroy_all(:kreuzschiene_id=>k)

						  if k.name = "Stagetec"
							 k.create_io_stagetek
							else
							 k.create_io
							end

							if attribut.size < 12

								k.update_attributes(:nummer=>'KV_0' + defi[2].to_i.to_s, :name=>attribut[0].to_s.strip, :protocol_id => attribut[1].to_s, :input => attribut[2].to_s, :output =>attribut[3].to_s,:unit => attribut[4].to_i,:port => attribut[5].to_i, :unit2 => attribut[6].to_i, :port2 => attribut[7].to_i, :ip => attribut[8].to_s, :ip2 => attribut[9].to_s)
							else
								attribut[10].to_i == 1 ? kr_type = "MIXER" : attribut[10].to_i == 2 ? kr_type = "MATRIX" : kr_type = ""

								k.update_attributes(:nummer=>'KV_0' + defi[2].to_i.to_s, :name=>attribut[0].to_s.strip, :protocol_id => attribut[1].to_s, :input => attribut[2].to_s, :output =>attribut[3].to_s,:unit => attribut[4].to_i,:port => attribut[5].to_i, :unit2 => attribut[6].to_i, :port2 => attribut[7].to_i, :ip => attribut[8].to_s, :ip2 => attribut[9].to_s, :kr_type => kr_type, :mixer_template_id => attribut[11])

							end
						end

				  # Devices   (SYSTEM-AWARE!)
				  elsif defi[0]=="SO" and defi[1]=="DEF" then

						attribut = tupel[1].split(",")
						d = Device.find_by_intnummer_and_system_id(defi[2].to_i, system_id)

						unless d.nil? then
							d.update_attributes(:nummer=>'DEV_0' + defi[2].to_i.to_s, :name=>attribut[0].to_s.strip, :protocol_id => attribut[1].to_i, :unit => attribut[2].to_i,:port => attribut[3].to_i, :ip => attribut[4].to_s)
						end

				  # Bediengeräte
				  elsif defi[0]=="BD" then

						attribut = tupel[1].split(",")

						if defi[1]=="DEF" then

					  if (!b.nil? and b.intnummer!=defi[2].to_i) then
							b = Bediengeraet.getBediengeraet(defi[2].to_i, system_id)
					  end

					  unless b.nil? then
							if b.respond_to?("label_quellen") && b.respond_to?("font_quellen") && b.respond_to?("label_split") && b.respond_to?("font_split")	&& b.respond_to?("label_senken")	&& b.respond_to?("font_senken")
				 				b.update_attributes(:nummer=>'BD_' + formatnumber2(defi[2].to_i), :name8stellig=>attribut[0].to_s.strip, :name4stellig=>attribut[1].to_s.strip,:unit=>attribut[2].to_s, :port=>attribut[3].to_s, :ip => attribut[5].to_s, :bdtype_id=>attribut[4].to_s, :upside_down => attribut[6].to_s, :vertical => attribut[7].to_s, :label_quellen => attribut[10].to_s, :font_quellen => attribut[11].to_s, :label_split => attribut[12].to_s, :font_split => attribut[13].to_s, :label_senken => attribut[14].to_s, :font_senken => attribut[15].to_s)
							else
								b.update_attributes(:nummer=>'BD_' + formatnumber2(defi[2].to_i), :name8stellig=>attribut[0].to_s.strip, :name4stellig=>attribut[1].to_s.strip,:unit=>attribut[2].to_s, :port=>attribut[3].to_s, :ip => attribut[5].to_s, :bdtype_id=>attribut[4].to_s, :upside_down => attribut[6].to_s, :vertical => attribut[7].to_s)
							end
							currsystem.createBDTypDummy(b.id,attribut[4].to_i)
							log.write("BD-DEF " + defi[2].to_i.to_s + " bid:" + b.id.to_s + " typ:" + attribut[4].to_i.to_s + "\n")
					  end

					elsif (defi[1]=="QTN") then

					  log.write("BD-QTN " + defi[2].to_i.to_s + " searching\n")

					  if (!b.nil? and b.intnummer!=defi[2].to_i) then
							b = Bediengeraet.getBediengeraet(defi[2].to_i, system_id)
							log.write("BD-QTN " + defi[2].to_i.to_s + " found\n")
					  end

					  if (!ts1.nil? and (ts1.bediengeraet_id.to_i!=b.id.to_i or ts1.tasten_id.to_i!=defi[3].to_i)) then
							ts1 = Typesource.find_by_bediengeraet_id_and_tasten_id_and_sourcetype(b.id, defi[3].to_i, 'normal')

							log.write("retrieving TS\n")
					  end
					  #if (!tt.nil? and (tt.bediengeraet_id!=b.id or tt.tasten_id!=defi[3].to_i)) then
						tt = Typetarget.find_by_bediengeraet_id_and_tasten_id(b.id, defi[3].to_i)
					  #end

					  prot = b.bdtype_id

					  unless b.nil? and b.normalquellen_kv_id==0 then
							kv = Kreuzschiene.find_by_intnummer_and_system_id(attribut[0], system_id)
							b.update_attribute('normalquellen_kv_id', kv.intnummer)
							log.write("BD-QTN Normalquellenupdate" + kv.intnummer.to_s + "\n")
					  end

					  log.write("BD-QTN prot: " + prot.to_s + "\n")

			  		if prot<3 or prot==4 then
						# Sonderfall BD_TYP_1/2, hier ist das
							unless ts1.nil? then
							  ts1.update_attributes(:source_id=>attribut[2])
							  log.write("BD-QTN TS_update 1" + attribut[2].to_s + "\n")

							end
							unless tt.nil? then
							  tt.update_attributes(:target_id=>attribut[1])
							end
					  elsif prot == 3
							# Sonderfall BD_TYP_3/4, hier ist das
							unless ts1.nil? then
							  ts1.update_attributes(:matrix => attribut[0], :source_id=>attribut[1])
							  log.write("BD-QTN TS_update 2" + attribut[2].to_s + "\n")
							end
					  elsif prot == 6
							unless ts1.nil? then
							  ts1.update_attributes(:source_id=>attribut[2])
							  log.write("BD-QTN TS_update 1" + attribut[2].to_s + "\n")
							end
					  else
							unless ts1.nil? then
							  ts1.update_attributes(:source_id=>attribut[1])
							  log.write("BD-QTN TS_update 2" + attribut[2].to_s + "\n")
							end
					  end

				elsif (defi[1]=="QTS") then

				  log.write("BD-QTS " + defi[2].to_i.to_s + " searching\n")
				  if (!b.nil? and b.intnummer!=defi[2].to_i) then
						b = Bediengeraet.getBediengeraet(defi[2].to_i, system_id)
						log.write("BD-QTS " + defi[2].to_i.to_s + " found\n")
				  end

				  if (!ts2.nil? and (ts2.bediengeraet_id.to_i!=b.id.to_i or ts2.tasten_id.to_i!=defi[3].to_i)) then
						ts2 = Typesource.find_by_bediengeraet_id_and_tasten_id_and_sourcetype(b.id, defi[3].to_i, 'split')
						log.write("retrieving TS\n")
				  end

				  if (!tt.nil? and (tt.bediengeraet_id!=b.id or tt.tasten_id!=defi[3].to_i)) then
						tt = Typetarget.find_by_bediengeraet_id_and_tasten_id(b.id, defi[3].to_i)
				  end

				  #prot = ts.bediengeraet.bdtype_id
				  prot = b.bdtype_id
					unless b.nil? and b.splitquellen_kv_id.nil? then
						kv = Kreuzschiene.find_by_intnummer_and_system_id(attribut[0], system_id)
						b.update_attribute('splitquellen_kv_id', kv.intnummer)
			  	end

			  	log.write("BD-QTS prot: " + prot.to_s + "\n")
			  	if prot<3 or prot==4 then

						unless ts2.nil? then
						  ts2.update_attributes(:source_id=>attribut[2])
						  log.write("BD-QTS " + b.id.to_s + " TS_update 3" + attribut[2].to_s + "\n")
						end
				# Sonderfall BD_TYP_1/2, hier ist das
						unless tt.nil? then
						  tt.update_attributes(:target_id=>attribut[2])
						end
				  elsif prot==3
						unless ts2.nil? then
						  ts2.update_attributes(:matrix => attribut[0], :source_id=>attribut[1])
						  log.write("BD-QTS TS_update 4" + attribut[2].to_s + "\n")
						end
				  else
						unless ts2.nil? then
						  ts2.update_attributes(:source_id=>attribut[1])
						  log.write("BD-QTS TS_update 4" + attribut[2].to_s + "\n")
						end
				  end
				elsif (defi[1]=="STN") then
			  	log.write("BD-STN " + defi[2].to_i.to_s + " searching\n")
			  	if (!b.nil? and b.intnummer!=defi[2].to_i) then
						b = Bediengeraet.getBediengeraet(defi[2].to_i, system_id)
						log.write("BD-STN " + defi[2].to_i.to_s + " found\n")
			  	end
			  	#if (!tt.nil? and tt.bediengeraet_id!=b.id and tt.tasten_id!=defi[3].to_i) then
					tt = Typetarget.find_by_bediengeraet_id_and_tasten_id(b.id, defi[3].to_i)
			  	#end
			  	prot = b.bdtype_id
			  	if prot==3 then
						unless tt.nil? then
				  		tt.update_attributes(:matrix => attribut[0], :target_id=>attribut[1])
						end
			  	elsif prot==6 then
						unless tt.nil? then
					  	tt.update_attributes(:target_id=>attribut[1])
						end
				  elsif prot==5 then
						unless tt.nil? then
						  tt.update_attributes(:target_id=>attribut[1])
						end
				  end
				end

		  # KV_I
		  # ;Salov Konfiguration KV_S_SalnoNr=Futureuse1,RowNr,Matrix,Senke,Quelle,Futureuse2_char3,Futureuse3
		  # KV_S_001=01,003,01,003,003,"   ",001
		  elsif defi[0]=="KV" then
			if defi[1]=="SS" then
				# KV_SS_001="demo1     "
				@salvo = Salvo.new(:intnummer => defi[2].to_i ,:name => tupel[1].strip ,:system_id => system_id)
				@salvo.save
				c=0
				128.times {
					c=c+1
					Crosspoint.new(:nummer=>c, :kreuzschiene_id=>nil, :salvo_id => @salvo.intnummer, :source_id=>nil, :target_id=>nil, :system_id=>system_id, :comment => '', :parameter => '', :value => '', :source_single_class => '', :source_subclass => '', :source_component => '', :source_subcomponent => '', :dest_single_class => '', :dest_subclass => '', :dest_component => '', :dest_subcomponent => '').save
				}
			elsif defi[1]=="S" then
				attribut = tupel[1].split(",")
				setup = Crosspoint.find_by_system_id_and_nummer_and_salvo_id(system_id, attribut[1].to_i, defi[2].to_i)
				kid = Kreuzschiene.find_by_system_id_and_intnummer(system_id, attribut[2].to_i)
				source = Source.find_by_kreuzschiene_id_and_intnummer(kid.id, attribut[4].to_i)
				target = Target.find_by_kreuzschiene_id_and_intnummer(kid.id, attribut[3].to_i)
				@salvo  = Salvo.find_by_intnummer_and_system_id(defi[2].to_i, system_id)
				@salvo.update_attributes(:salvo_type => attribut[0])
				unless setup.nil? then
					if attribut[0][-1,1].to_i==0
						setup.update_attributes(:kreuzschiene_id=>kid.id, :target_id=>target.id, :source_id=>source.id)
					elsif attribut[0][-1,1].to_i==1
						data = attribut[5].split('.');
						#stack = data[0].to_s+"."+(data[1].to_i).to_s
						frame = data[2]
						slot = data[3]
						setup.update_attributes(:stack1 => data[0].to_s,:stack2 => data[1].to_s, :frame => frame, :slot => slot, :parameter => attribut[13], :value => attribut[14], :comment => attribut[15])

					elsif attribut[0][-1,1].to_i==2


						setup.update_attributes(:source_single_class => attribut[5], :source_subclass => attribut[6].to_i, :source_component => attribut[7].to_i, :source_subcomponent => attribut[8].to_i,:dest_single_class => attribut[9],:dest_subclass => attribut[10].to_i,:dest_component => attribut[11].to_i,:dest_subcomponent => attribut[12].to_i,:parameter => '', :value => '', :comment => '')
					end
				end

			elsif defi[1]=="I" then

			  k = Kreuzschiene.find_by_system_id_and_intnummer(system_id, defi[2].to_i)
			  #opt = @vs_nr.value.to_i

			  attribut = tupel[1].split(",")

			  s = Source.find_by_kreuzschiene_id_and_intnummer(k.id,defi[3].to_i)
			  unless s.nil? then

				attribut[0].nil? ? n5s = "" : n5s = attribut[0].strip
				attribut[1].nil? ? n4s = "" : n4s = attribut[1].strip
				attribut[2].nil? ? ch6 = "" : ch6 = attribut[2].strip
				attribut[3].nil? ? ch10 = "" : ch10 = attribut[3].strip

				if k.kr_type == "MATRIX" && !k.matrix_type.nil? && k.matrix_type.title == "Lawo MONPL"
					attribut[4].strip == "000" ? tb = "" : tb = attribut[4].strip.to_i
					if !attribut[5].nil? && !attribut[6].nil?
						mtx = attribut[5].strip.to_i
					else
						mtx = ""
					end
					attribut[6].strip == "00" ? ql = "" : ql = attribut[6].strip.to_i
					attribut[7].nil? ? cm = "" : cm = attribut[7].strip
					hexa = "0x"+sprintf("%0x",attribut[8].strip.to_i).to_s
					if SignalQuellen.exists?(["hexa = ?",hexa])
						signal = SignalQuellen.find_by_hexa(hexa).intnummer
					else
						signal = nil
					end
					s.update_attributes(:name5stellig => n5s.strip, :name4stellig => n4s.strip, :char6 => ch6.strip, :char10 => ch10.strip, :tallybit => tb.to_s, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => cm.strip, :signal => signal, :subclass => attribut[9].strip.to_i, :component => attribut[10].strip.to_i, :subcomponent => attribut[11].strip.to_i, :family_id =>(attribut[12].nil? ? 0:attribut[12]))


				elsif k.kr_type == "MATRIX" && !k.matrix_type.nil? && k.matrix_type.title == "Stagetec"
					if !attribut[4].nil?
						attribut[4].strip == "000" ? tb = "" : tb = attribut[4].strip.to_i
					else
						tb = ""
					end
					if !attribut[5].nil? && !attribut[6].nil?
						mtx = attribut[5].strip.to_i
					else
						mtx = ""
					end
					if !attribut[6].nil?
						attribut[6].strip == "00" ? ql = "" : ql = attribut[6].strip.to_i
					else
						ql = ""
					end
					attribut[7].nil? ? cm = "" : cm = attribut[7].strip
					attribut[9].nil? ? real_input = "" : real_input = attribut[9].strip

					s.update_attributes(:name5stellig => n5s.strip, :name4stellig => n4s.strip, :char6 => ch6.strip, :char10 => ch10.strip, :tallybit => tb.to_s, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => cm.strip, :real_input => real_input, :family_id => !attribut[10].nil? ? attribut[10].strip.to_i : 0)
				elsif k.kr_type == "MIXER"
					attribut[4].strip == "000" ? tb = "" : tb = attribut[4].strip.to_i
					!attribut[5].nil? && !attribut[6].nil? ? mtx = attribut[5].strip.to_i : mtx = ""
					attribut[6].strip == "00" ? ql = "" : ql = attribut[6].strip.to_i
					attribut[7].nil? ? cm = "" : cm = attribut[7].strip

					s.update_attributes(:name5stellig => n5s.strip, :name4stellig => n4s.strip, :char6 => ch6.strip, :char10 => ch10.strip, :tallybit => tb.to_s, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => cm.strip, :channel => attribut[8].to_i, :family_id => ( (!attribut[9].nil?) ? attribut[9].strip.to_i : 0), :par_matrix => (( !attribut[10].nil? && (attribut[10].to_i != 0) ) ? attribut[10].strip.to_i : nil), :par_quelle => ( ( !attribut[11].nil? && (attribut[11].to_i != 0) ) ? attribut[11].strip.to_i : nil ) )
				else


					if attribut.size < 6
						attribut[4].nil? ? cm = "" : cm = attribut[4].strip

						s.update_attributes(:name5stellig => n5s.strip, :name4stellig => n4s.strip, :char6 => n5s.strip, :char10 => n5s.strip, :comment => n5s.strip, :family_id => (!attribut[attribut.length - 1].nil? ? attribut[attribut.length - 1].strip.to_i : 0))
					else

						attribut[4].strip == "000" ? tb = "" : tb = attribut[4].strip.to_i
						!attribut[5].nil? && !attribut[6].nil? ? mtx = attribut[5].strip.to_i : mtx = ""
						attribut[6].strip == "00" ? ql = "" : ql = attribut[6].strip.to_i
						attribut[7].nil? ? cm = "" : cm = attribut[7].strip

						s.update_attributes(:name5stellig => !n5s.nil? ? n5s.strip : "", :name4stellig => !n4s.nil? ? n4s.strip : "", :char6 => !ch6.nil? ? ch6.strip : "", :char10 => !ch10.nil? ? ch10.strip : "", :tallybit => tb.to_s, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => !cm.nil? ? cm.strip : "", :channel => attribut[8].to_i, :family_id => !attribut[9].nil? ? attribut[9].strip.to_i : 0,:green => attribut[10].to_i != 0 ? attribut[10].strip.to_i : 0, :yellow => attribut[11].to_i != 0 ? attribut[11].strip.to_i : 0, :blue => attribut[12].to_i != 0 ? attribut[12].strip.to_i : 0)
					end
				end

			  end

			# KV_O
			elsif defi[1]=="O" then

			  k = Kreuzschiene.find_by_system_id_and_intnummer(system_id, defi[2].to_i)
			  #opt = @vs_nr.value.to_i

			  attribut = tupel[1].split(",")
			  t = Target.find_by_kreuzschiene_id_and_intnummer(k.id,defi[3].to_i)

			  unless t.nil? then
				attribut[0].nil? ? n5s = "" : n5s = attribut[0].strip
				attribut[1].nil? ? n4s = "" : n4s = attribut[1].strip
				attribut[2].nil? ? ch6 = "" : ch6 = attribut[2].strip
				attribut[3].nil? ? ch10 = "" : ch10 = attribut[3].strip

				if k.kr_type == "MATRIX" && !k.matrix_type.nil? && k.matrix_type.title == "Lawo MONPL"
					mtx = attribut[4].strip.to_i
					attribut[5].strip == "00" ? ql = "" : ql = attribut[5].strip.to_i
					attribut[6].nil? ? cm = "" : cm = attribut[6].strip
					hexa = "0x"+sprintf("%0x",attribut[7].strip.to_i).to_s
					if SignalQuellen.exists?(["hexa = ?",hexa])
						signal = SignalSenken.find_by_hexa(hexa).intnummer
					else
						signal = nil


					end

					t.update_attributes(:name5stellig=>n5s.strip, :name4stellig=>n4s.strip, :char6 => ch6.strip, :char10 => ch10.strip, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => cm.strip, :signal => attribut[7].strip.to_i, :subclass => attribut[8].strip.to_i, :component => attribut[9].strip.to_i, :subcomponent => attribut[10].strip.to_i, :family_id => (!attribut[attribut.length - 2].nil? ? attribut[attribut.length - 2].strip.to_i : 0))
				elsif k.kr_type == "MATRIX" && !k.matrix_type.nil? && k.matrix_type.title == "Stagetec"
					if !attribut[4].nil?
						mtx = attribut[4].strip.to_i
					else
						mtx = ""
					end
					if !attribut[5].nil?
						attribut[5].strip == "00" ? ql = "" : ql = attribut[5].strip.to_i
					else
						ql = ""
					end
					attribut[6].nil? ? cm = "" : cm = attribut[6].strip
					attribut[8].nil? ? real_output = "" : real_output = attribut[8].strip

					t.update_attributes(:name5stellig=>n5s.strip, :name4stellig=>n4s.strip, :char6 => ch6.strip, :char10 => ch10.strip, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => cm.strip, :real_output => real_output, :family_id => (!attribut[attribut.length - 1].nil? ? attribut[attribut.length - 1].strip.to_i : 0) )
				else
					if attribut.size < 6
						attribut[4].nil? ? cm = "" : cm = attribut[4].strip

						t.update_attributes(:name5stellig=>n5s.strip, :name4stellig=>n4s.strip, :char6 => n5s.strip, :char10 => n5s.strip, :comment => n5s.strip, :family_id => (!attribut[attribut.length - 1].nil? ? attribut[attribut.length - 1].strip.to_i : 0) )
					else
						mtx = attribut[4].strip.to_i
						attribut[5].strip == "00" ? ql = "" : ql = attribut[5].strip.to_i
						attribut[6].nil? ? cm = "" : cm = attribut[6].strip
						t.update_attributes(:name5stellig=>n5s.strip, :name4stellig=>n4s.strip, :char6 => ch6.strip, :char10 => ch10.strip, :matrix => mtx.to_s, :quelle => ql.to_s, :comment => cm.strip, :channel => attribut[7].to_i,:family_id => (!attribut[8].nil? ? attribut[8].strip.to_i : 0), :red => (!attribut[9].nil? ? attribut[9].strip.to_i : 0), :green => (!attribut[10].nil? ? attribut[10].strip.to_i : 0), :yellow => (!attribut[11].nil? ? attribut[11].strip.to_i : 0), :blue => (!attribut[12].nil? ? attribut[12].strip.to_i : 0) )
					end
				end
			  end

			elsif defi[1]=="REE" then
			# KV_REE_QUELLE=00,005,01,001
			# KV_REE_SENKE=00,030,01,001,004
			# KV_REE_SENKE=01,001,00,001

				attribut = tupel[1].split(",")
				k = Kreuzschiene.find_by_system_id_and_intnummer(system_id, attribut[0].to_i)
				if defi[2]=="QUELLE" then
					s = Source.find_by_kreuzschiene_id_and_intnummer(k.id, attribut[1].to_i)
					s.update_attributes(:mx_matrix => attribut[2].to_i, :mx_senke => attribut[3].to_i, :enable => attribut[4].to_i)

				elsif defi[2]=="SENKE" then
					if attribut.size == 4
						t = Target.find_by_kreuzschiene_id_and_intnummer(k.id, attribut[1].to_i)
						t.update_attributes(:mx_matrix => attribut[2].to_i, :mx_quelle => attribut[3].to_i)
					else
						t = Target.find_by_kreuzschiene_id_and_intnummer(k.id, attribut[4].to_i)
						t.update_attributes(:mx_tallybit => attribut[1].to_i, :mx_matrix => attribut[2].to_i, :mx_quelle => attribut[3].to_i)
					end
				end

			end

		  # Clon_tally
		  elsif defi[0]=="CLON" then
			if defi[1]=="TALLY" then
				attribut = tupel[1].split(",")
				k = Kreuzschiene.find_by_system_id_and_intnummer(system_id, attribut[0].to_i)
				s = Source.find_by_kreuzschiene_id_and_intnummer(k.id, attribut[1].to_i)
				unless s.nil? then
					attribut[2].to_i == 0 ? cl = nil : cl = attribut[2].to_i
					s.update_attributes(:cloneinput => "#{cl}")
				end
			end

		  # Frames
		  elsif defi[0]=="MI" and defi[1]=="T" then
			bme = Bme.find_by_taste_and_system_id(defi[3].to_i, system_id)
			unless bme.nil? then
			  bme.update_attributes(:source_id=>tupel[1])
			end

		  # UMD DEV KV                                SYSTEM-AWARE
		  elsif defi[0]=="UMD" then
			if defi[1]=="DEF" then
				attribut = tupel[1].split(",")
				u = Umd.find_by_intnummer_and_system_id(defi[3].to_i, system_id)

				if defi[2]=="KV" then
				  unless u.nil? then
					kv = Kreuzschiene.find_by_intnummer_and_system_id(attribut[0], system_id)
					u.update_attributes(:kreuzschiene_id=>kv.id, :target_id=>attribut[1], :choice => attribut[3].nil? ? nil : attribut[3][-1,1])
				  end

				elsif defi[2]=="TXT" then
				  unless u.nil? then
					u.update_attributes(:festtext=>attribut[0].strip)
				  end

				elsif defi[2]=="MON" then
				  unless u.nil? then
					u.update_attributes(:monitor=>attribut[0], :gpi=>attribut[2])
				  end

				elsif defi[2]=="HAV" then
				  unless u.nil? then
					u.update_attributes(:bme=>attribut[0])
				  end

				elsif defi[2]=="KVH" then
				  unless u.nil? then
					u.update_attributes(:mon_havarie=>attribut[0])
				  end

				elsif defi[2]=="CON" then
				  unless u.nil? then
					u.update_attributes(:konfiguration=>attribut[0])
				  end
				elsif defi[2]=="CHOICE" then
				  unless u.nil? then
					#u.update_attributes(:choice=>attribut[0][-1,1], :type_option=>attribut[1][-1,1],:ip_address =>attribut[2].strip,:panel=>attribut[3],:vts_input=>attribut[4])
					u.update_attributes(:type_option=>attribut[1][-1,1],:ip_address =>attribut[2].strip,:panel=>attribut[3],:vts_input=>attribut[4])
				  end
				end
			elsif defi[1]=="PGM" then
			  u = Umd.find_by_intnummer_and_system_id(tupel[1].to_i, system_id)
			  u.update_attributes(:pgm_monitor => "1")
			end

			# SENDE_BD = panel_id, matrix_id, senke_id
		elsif defi[0]=="SENDE" then
			if defi[1]=="BD" then
				attribut = tupel[1].split(",")
				p = Bediengeraet.find_by_system_id_and_intnummer(system_id, attribut[0].to_i)
				unless p.nil? then
				  p.update_attributes(:sende_matrix_id => attribut[1].to_i, :sende_senke_id => attribut[2].to_i)
				end
			end

			  # MIX_TAST= intnummer, senke of kv1
		elsif defi[0]=="MIX" then
			attribut = tupel[1].split(",")
			b = Bme.find_by_taste_and_system_id(attribut[0].to_i, system_id)
			b.update_attributes(:peview_monitor => attribut[1].to_i)
		elsif defi[0]=="SYSCOL" then
			attribut = tupel[1].split(",")
			SystemColor.create(:nummer => defi[1], :red => attribut[0].to_i*2,:green=> attribut[1].to_i*2, :blue=>attribut[2].to_i*2, :name => attribut[3])
		elsif defi[0]=="FAMILY" then
			attribut = tupel[1].split(",")
			Family.create(:nummer => defi[1], :system_color_id => attribut[0],:name=> attribut[1], :position => defi[1])
		elsif defi[0]=="MATCHING"
			attribut = tupel[1].split(",")
			count = SystemMatching.count(:conditions => ["system_id = ?",system_id])
			if count==0
				nummer = 1
			else
				nummer = count+1
			end
			SystemMatching.create(:system_id => system_id, :intnummer => nummer, :matching_panel => attribut[0], :matching_set => defi[1], :matching_start_quelle => attribut[1], :matching_end_quelle => attribut[2], :matching_matrix => attribut[3], :matching_senke => attribut[4])
		elsif defi[0]=="ASSOZIATION"
			attribut = tupel[1].split(",")
			SystemAssoziation.create(:system_id => system_id, :intnummer => defi[2], :source_matrix => attribut[0], :source_senke => attribut[1], :matrix_1 => attribut[2], :senke_1 => attribut[3], :matrix_2 => attribut[4], :senke_2 => attribut[5], :matrix_3 => attribut[6], :senke_3 => attribut[7])
		end
		end
        end
      end # transaction
      end

    #flash[:notice]="Version " + currsystem.version.to_s + " wurde mit " + zeile.to_s + " Zeilen von <b>" + datasource.to_s + "</b> in den Konfigurationsspeicher " + system_id.to_s + " eingelesen"
    #log.write("Version " + currsystem.version.to_s + " wurde mit " + zeile.to_s + " Zeilen von <b>" + datasource.to_s + "</b> in den Konfigurationsspeicher " + system_id.to_s + " eingelesen")
    log.close


    # => GPIO Section
    #if File.exist?("#{RAILS_ROOT}/conf/#{system_id}/gpio.conf")
    if File.exist?("#{RAILS_ROOT}/conf/gpio.conf")
        log = File.open("#{RAILS_ROOT}/log/import_gpio_log.txt", 'w')
        log.write("----==============----\n")
        log.write("System " + currsystem.id.to_s + "\n")

        gpio = File.open("#{RAILS_ROOT}/conf/gpio.conf", 'r')

        GpInput.clear_system_values(system_id)
        GpOutput.clear_system_values(system_id)
        gpio.each do |line|
            if line.match(/^DEF_GPIO_IN_\d/)
                formatted_line = line.split("DEF_GPIO_IN_")
                formatted_line.shift
                values = formatted_line[0].split("=")
                if values[0].to_i == 1
                    input_value = 1001
                else
                    input_value = GpInput.find_by_intnummer(values[0].to_i - 1).value + 1
                end
                field_values = values[1].split(",").map{|x| x.gsub('"','')}.map{|x| x.strip}
                log.write("#{field_values.inspect}\n")
#                DEF_GPIO_IN_NrofInput="16charName      ",Type,Unit/Panel,Port,Byte,Bit,Invert,RadioButton Group,"16charComment   "
                input = GpInput.new({:intnummer => values[0].to_i,
                                     :name => field_values[0],
                                     :system_id => system_id,

                                     :i_type => field_values[1].to_i,
                                     :unit => field_values[2].to_i,
                                     :port => field_values[3].to_i,
                                     :byte => field_values[4].to_i,
                                     :bit => field_values[5].to_i,
                                     :invert => field_values[6].to_i,
                                     :radio => field_values[7].to_i,
                                     :comment => field_values[8],
                                     :value => input_value
                                     }).save
            end

            if line.match(/^DEF_GPIO_OUT_\d/)
                formatted_line = line.split("DEF_GPIO_OUT_")
                formatted_line.shift
                values = formatted_line[0].split("=")
                field_values = values[1].split(",").map{|x| x.gsub('"','')}.map{|x| x.strip}
                if values[0].to_i == 1
                    input_value = 2001
                else
                    input_value = GpOutput.find_by_intnummer(values[0].to_i - 1).value + 1
                end
#               DEF_GPIO_OUT_Nrofoutput="16char Name     ","16cha ActiveName",16cha Inact Name",Mode,Type,Unit/Panel,Port,Byte,Bit,Invert,Comment
                input = GpOutput.new({:intnummer => values[0].to_i,
                                     :name => field_values[0],
                                     :system_id => system_id,
                                     :active_name => field_values[1],
                                     :inactive_name => field_values[2],
                                     :mode => field_values[3].to_i,
                                     :o_type => field_values[4].to_i,

                                     :unit => field_values[5].to_i,
                                     :port => field_values[6].to_i,
                                     :byte => field_values[7].to_i,
                                     :bit => field_values[8].to_i,
                                     :invert => field_values[9].to_i,
                                     :comment => field_values[10],
                                     :value => input_value
                                     }).save
            end
        end

				f_new_conf = File.new("#{RAILS_ROOT}/conf/#{@system.id}/gpio.conf","w")

				File.open("#{RAILS_ROOT}/conf/gpio.conf", 'r').each do |e|
					f_new_conf.write(e)
				end

				f_new_txt = File.new("#{RAILS_ROOT}/conf/#{@system.id}/gpio.txt","w")

				File.open("#{RAILS_ROOT}/conf/gpio.txt", 'r').each do |e|
					f_new_txt.write(e)
				end
    end

		@content = Option.getIbtContent
		@content.update_attributes(:value => ibt_content)
	end

	def undo_software_update
                dir_to_copy = Dir[RAILS_ROOT + "/../*"].select {|f| test ?d, f}.sort_by {|f| File.mtime f}.map!{|x| File.basename(x)}.select{|x| x if (x =~ /config/) == 11}[0]
                time_stamp = DateTime.now.strftime("%d-%m-%Y")
                parent_path = Pathname.new(RAILS_ROOT).parent.realpath.to_s
                rails_root = parent_path + "/config"
                cp_path = parent_path + "/#{time_stamp}_config_bak"
                FileUtils.cp_r rails_root, cp_path
                FileUtils.rm_rf Dir.glob(rails_root+ "/*")
                FileUtils.cp_r(parent_path + "/" + dir_to_copy  + "/.", rails_root)
                sleep 2
                `mysql -u root config < #{RAILS_ROOT}/db/old_sql/config.sql`
                render :action => "restart"
	end


	def clear_logs
	      if File.exist?("#{RAILS_ROOT}/log/development.log")
		      FileUtils.rm_rf("#{RAILS_ROOT}/log/development.log")
	      end
	      File.new("#{RAILS_ROOT}/log/development.log","w")
	      redirect_to :action => :index
	end

	class ZipThemAll
		attr_accessor :list_of_file_paths, :zip_file_path
		def initialize( zip_file_path, list_of_file_paths )
		    @zip_file_path = zip_file_path
		    list_of_file_paths = [list_of_file_paths] if list_of_file_paths.class == String
		    @list_of_file_paths = list_of_file_paths
		end

		def zip
		    zip_file = Zip::ZipFile.open(self.zip_file_path, Zip::ZipFile::CREATE)
		    self.zip_em_all( zip_file, @list_of_file_paths )
		    zip_file.close
		end

		def zip_em_all( zip_file, file_list, sub_directory=nil )
		    file_list.each do | file_path |
		      if File.exists?file_path
			 if File.directory?( file_path )
		          file_directory_list = []
		          # Find.find( file_path ) do | path |
		          file_directory_list = Dir.entries( file_path )
		          file_directory_list.delete(".")
		          file_directory_list.delete("..")
		          file_directory_list = file_directory_list.inject([]) do | result, path |
		            result << file_path + "/" + path
		            result
		         end
		         self.zip_em_all( zip_file, file_directory_list, (sub_directory == nil ? '.' : sub_directory) + "/" + File.basename(file_path) )
		      else
		          file_name = File.basename( file_path )
		          if sub_directory != nil
		            if zip_file.find_entry( sub_directory ) == nil
		              dir = zip_file.mkdir( sub_directory )
		            end
		            file_name = sub_directory + "/" + file_name
		          end
		          if zip_file.find_entry( file_name )
		            zip_file.replace( file_name, file_path )
		          else
		            zip_file.add( file_name, file_path)
		          end
		      end
	      else
		puts "Warning: file #{file_path} does not exist"
	      end
	    end
	  end
	end

	def firmware_update
		require 'Multi_FTP'
		require 'timeout'
		if request.post?
			@upload_file_name = params['firmware'].original_filename
			@upload_file_type = params['firmware'].content_type

			if File.exist?("#{RAILS_ROOT}/public/files/#{@upload_file_name}")
			  FileUtils.rm_rf("#{RAILS_ROOT}/public/files/#{@upload_file_name}")
			end

			File.open("#{RAILS_ROOT}/public/files/#{@upload_file_name}", "wb") do |f|
				f.write(params['firmware'].read)
			end
			zip_source = "#{RAILS_ROOT}/public/files/#{@upload_file_name}"
			unzip_file(zip_source, "#{RAILS_ROOT}/conf/hardware_upd")

			ftpdest = ''
			system_id = cookies[:system_id]
			@system = System.find(system_id)

			@system.frames.each_with_index do |frame,index|
			 if frame.ipadresse.size > 0 then
			    veto = 0
			    logger.info(">>FTP: " + frame.ipadresse + " " + Global::FTPUSER + " " + Global::FTPPASSWD)
			    ftp = nil

			    begin
			       timeout(Global::CON_TIMEOUT) do
				  logger.info(">>FTP: trying to connect #{frame.ipadresse}")
				  ftp = Multi_FTP.new()

				  #ftp.setup("hb", "hbdev","192.168.33.157")
				  ftp.setup("#{Global::FTPUSER}","#{Global::FTPPASSWD}",frame.ipadresse)
			       end
			       logger.info(">>FTP connect successfully " + frame.ipadresse)
			    rescue Net::FTPPermError => msg
			       ftpdest = ftpdest + "<font color='red'>Fehler Login: " + frame.ipadresse + "</font><br />"
			       logger.info(">>FTP error connect ")
			       veto = 1
			       GC.start
			       sleep Global::CLOSE_TIMEOUT
			    rescue Timeout::Error => msg
			       ftpdest = ftpdest + "<font color='red'>Fehler Timeout: " + frame.ipadresse + "</font><br />"
			       logger.info(">>FTP error connect ")
			       veto = 1
			       GC.start
			       sleep Global::CLOSE_TIMEOUT
			    end
			    # Bei Verbindung Daten holen versuchen
			    ftpdest = ""
			    unless veto==1 then
			       begin
				  timeout(Global::TRANSFER_TIMEOUT) do
					num = index+1
					ftp.go_send("#{RAILS_ROOT}/conf/hardware_upd/","#{Global::FTPDIR}/")
				  end
				  logger.info(">>FTP: done for " + frame.ipadresse)
				  ftpdest = ftpdest + "<font color='green'><b>Übertragung nach " + frame.ipadresse + " erfolgreich</b></font><br />"
			       rescue Timeout::Error => msg
				  logger.info(">>FTP error " + msg)
				  ftpdest = ftpdest + "<font color='red'>Fehler1 Übertragung nach " + frame.ipadresse + "<br />" + "</font>"
			       rescue Exception => e
				  render :text => [e.message,e.application_backtrace].inspect and return false
				  ftpdest = ftpdest + "<font color='red'>Fehler2 Übertragung nach " + frame.ipadresse + "<br />" + "</font>"
			       ensure
				  #ftp.close if ftp
				  GC.start
				  sleep Global::CLOSE_TIMEOUT
			       end
			    end
			 end
			end
			flash[:notice] = "Firmware Updated successfully."
			redirect_to :action => "show", :id=>system_id
		end
	end

	def unmount_and_reboot
		require 'net/telnet'
		system_id = cookies[:system_id]
		@system = System.find(system_id)
		ftpdest = ""
		@system.frames.each_with_index do |frame,index|
			if frame.ipadresse.size > 0 then
				begin
					localhost = Net::Telnet::new("Host" => "#{frame.ipadresse}")
					localhost.login("#{Global::FTPUSER}") { |c| print c }
					if localhost.cmd("umount hd") { |c| print c }
						localhost.cmd("reboot") { |c| print c }
					end
					localhost.close
					ftpdest = ftpdest + "<font color='green'><b>Unit : #{index+1} (" + frame.ipadresse + ") umount and reboot successfully</b></font><br />"
				rescue Timeout::Error => msg
					ftpdest = ftpdest + "<font color='red'>Connection Timeout " + frame.ipadresse + "&nbsp; Unit : #{index+1} <br />" + "</font>"
				rescue Errno::EHOSTUNREACH => msg
					ftpdest = ftpdest + "<font color='red'>Can't connect with host" + frame.ipadresse + "&nbsp; Unit : #{index+1} <br />" + "</font>"
			       	end
			end
		end
		flash[:notice] = ftpdest
		redirect_to :action => "show", :id=>system_id
	end

	def panel_firmware_update
		require 'Multi_FTP'
		require 'timeout'
		if request.post?
			@upload_file_name = params['panel_firmware'].original_filename
			@upload_file_type = params['panel_firmware'].content_type
			FileUtils.rm_rf("#{RAILS_ROOT}/conf/panel_upd/.")

			if File.exist?("#{RAILS_ROOT}/public/files/#{@upload_file_name}")
			  FileUtils.rm_rf("#{RAILS_ROOT}/public/files/#{@upload_file_name}")
			end

			File.open("#{RAILS_ROOT}/public/files/#{@upload_file_name}", "wb") do |f|
				f.write(params['panel_firmware'].read)
			end
			ext = File.extname("#{RAILS_ROOT}/public/files/#{@upload_file_name}")
			if ext == ".zip"
				zip_source = "#{RAILS_ROOT}/public/files/#{@upload_file_name}"
				unzip_file(zip_source, "#{RAILS_ROOT}/conf/panel_upd")
			else
				FileUtils.cp "#{RAILS_ROOT}/public/files/#{@upload_file_name}","#{RAILS_ROOT}/conf/panel_upd/#{@upload_file_name}"
			end

			ftpdest = ''
			system_id = cookies[:system_id]
			@panels = Bediengeraet.find(:all, :conditions => ["system_id = ? and ip != ''", system_id])
			for frame in @panels
			 if frame.ip.size > 0 then
			    veto = 0
			    logger.info(">>FTP: " + frame.ip + " " + Global::FTPUSER + " " + Global::FTPPASSWD)
			    ftp = nil

			    # Bei Verbindung Daten holen versuchen
			    unless veto==1 then
						begin
							ip = frame.ip.split(".").map{|x| x.to_i}.join(".")
							path_var = RAILS_ROOT.gsub("/InstantRails-2.0-win/rails_apps/config","")
							Dir.foreach("#{RAILS_ROOT}/conf/panel_upd/") {|x|
										if x!='.' && x!='..'
											system("cd #{path_var} && ncftpput -u #{Global::FTPUSER} -p #{Global::PANEL_FTPPASSWD} #{ip} /bin #{RAILS_ROOT}/conf/panel_upd/#{x}")
										end
							}
							logger.info(">>FTP: done for " + frame.ip)
							ftpdest = ftpdest + "<font color='green'><b>Übertragung nach " + frame.ip + " erfolgreich</b></font><br />"
						rescue Timeout::Error => msg
							logger.info(">>FTP error " + msg)
							ftpdest = ftpdest + "<font color='red'>Fehler1 Übertragung nach " + frame.ip + "<br />" + "</font>"
						rescue Exception => e
							ftpdest = ftpdest + "<font color='red'>Fehler2 Übertragung nach " + frame.ip + "<br />" + "</font>"
						ensure
							GC.start
							sleep Global::CLOSE_TIMEOUT
						end
			    end
			 end
			end
			flash[:notice] = ftpdest
			redirect_to :action => "show", :id=>system_id
		end
	end

	def panel_firmware_update_one
		system_id = cookies[:system_id]
		@system_panels = Bediengeraet.find(:all, :conditions => ["system_id = ? and ip != ''", system_id])
		require 'Multi_FTP'
		require 'timeout'
		if request.post?
			@upload_file_name = params['panel_firmware'].original_filename
			@upload_file_type = params['panel_firmware'].content_type
			FileUtils.rm_rf("#{RAILS_ROOT}/conf/panel_upd/.")

			if File.exist?("#{RAILS_ROOT}/public/files/#{@upload_file_name}")
			  FileUtils.rm_rf("#{RAILS_ROOT}/public/files/#{@upload_file_name}")
			end

			File.open("#{RAILS_ROOT}/public/files/#{@upload_file_name}", "wb") do |f|
				f.write(params['panel_firmware'].read)
			end
			ext = File.extname("#{RAILS_ROOT}/public/files/#{@upload_file_name}")
			if ext == ".zip"
				zip_source = "#{RAILS_ROOT}/public/files/#{@upload_file_name}"
				unzip_file(zip_source, "#{RAILS_ROOT}/conf/panel_upd")
			else
				FileUtils.cp "#{RAILS_ROOT}/public/files/#{@upload_file_name}","#{RAILS_ROOT}/conf/panel_upd/#{@upload_file_name}"
			end

			ftpdest = ''
			@panels = Bediengeraet.find(:all, :conditions => ["id = ?",params[:panel][:panel]])
			for frame in @panels
			if frame.ip.size > 0 then
			    veto = 0
			    logger.info(">>FTP: " + frame.ip + " " + Global::FTPUSER + " " + Global::FTPPASSWD)
			    ftp = nil
			    # Bei Verbindung Daten holen versuchen
			    unless veto==1 then
			       begin
							ip = frame.ip.split(".").map{|x| x.to_i}.join(".")
							path_var = RAILS_ROOT.gsub("/InstantRails-2.0-win/rails_apps/config","")
							Dir.foreach("#{RAILS_ROOT}/conf/panel_upd/") {|x|
										if x!='.' && x!='..'
											system("cd #{path_var} && ncftpput -u #{Global::FTPUSER} -p #{Global::PANEL_FTPPASSWD} #{ip} /bin #{RAILS_ROOT}/conf/panel_upd/#{x}")
										end
							}
							logger.info(">>FTP: done for " + frame.ip)
							ftpdest = ftpdest + "<font color='green'><b>Übertragung nach " + frame.ip + " erfolgreich</b></font><br />"
			       rescue Timeout::Error => msg
							logger.info(">>FTP error " + msg)
							ftpdest = ftpdest + "<font color='red'>Fehler1 Übertragung nach " + frame.ip + "<br />" + "</font>"
			       rescue Exception => e
							ftpdest = ftpdest + "<font color='red'>Fehler2 Übertragung nach " + frame.ip + "<br />" + "</font>"
			       ensure
							GC.start
							sleep Global::CLOSE_TIMEOUT
			       end
			    end
			 end
			end
			flash[:notice] = ftpdest
			redirect_to :action => "show", :id=>system_id
		end
	end

	def panel_reboot
		require 'net/telnet'
		system_id = cookies[:system_id]
		@system = System.find(system_id)
		@panels = Bediengeraet.find(:all, :conditions => ["system_id = ? and ip!=''",system_id])
		ftpdest = ""
		@panels.each do |frame, index|
			if frame.ip.size > 0 then
				begin
					localhost = Net::Telnet::new("Host" => "#{frame.ip}")
					localhost.cmd("reboot") { |c| print c }
					localhost.close
					ftpdest = ftpdest + "<font color='green'><b>Panel (" + frame.ip + ") reboot successfully</b></font><br />"
				rescue Timeout::Error => msg
					ftpdest = ftpdest + "<font color='red'>Connection Timeout " + frame.ip + "&nbsp; <br />" + "</font>"
				rescue Errno::EHOSTUNREACH => msg
					ftpdest = ftpdest + "<font color='red'>Can't connect with host" + frame.ip + "&nbsp;<br />" + "</font>"
			       	end
			end
		end
		flash[:notice] = ftpdest
		redirect_to :action => "show", :id=>system_id
	end

	def panel_reboot_one
		require 'net/telnet'
		system_id = cookies[:system_id]
		@system = System.find(system_id)
		@system_panels = Bediengeraet.find(:all, :conditions => ["system_id = ? and ip != ''", system_id])

		if request.post?
			@panels = Bediengeraet.find(:all, :conditions => ["id = ?",params[:panel][:panel]])
			ftpdest = ""
			@panels.each do |frame, index|
				if frame.ip.size > 0 then
					begin
						localhost = Net::Telnet::new("Host" => "#{frame.ip}")
						localhost.cmd("reboot") { |c| print c }
						localhost.close
						ftpdest = ftpdest + "<font color='green'><b>Panel (" + frame.ip + ") reboot successfully</b></font><br />"
					rescue Timeout::Error => msg
						ftpdest = ftpdest + "<font color='red'>Connection Timeout " + frame.ip + "&nbsp; <br />" + "</font>"
					rescue Errno::EHOSTUNREACH => msg
						ftpdest = ftpdest + "<font color='red'>Can't connect with host" + frame.ip + "&nbsp; <br />" + "</font>"
				       	end
				end
			end
			flash[:notice] = ftpdest
			redirect_to :action => "show", :id=>system_id
		end
	end

	def update_matching
		if request.post?
			render :update do |page|
				@system_matching = SystemMatching.find(params[:id])
				if !params[:system_matching][:matching_matrix].nil? && @system_matching.matching_matrix != params[:system_matching][:matching_matrix]
					@update_senke = 1
				end
				@system_matching.update_attributes(params[:system_matching])
				if @update_senke == 1
					page.replace_html "system_mathching_sn_#{@system_matching.id}", :partial => "getSenke_matching", :locals => {:matching => @system_matching.matching_matrix}
				end
			end
		end
	end

	def update_assoziation
		if request.post?
			render :update do |page|
				@system_assoziation = SystemAssoziation.find(params[:id])
				if !params[:system_assoziation][:source_matrix].nil? && @system_assoziation.source_matrix != params[:system_assoziation][:source_matrix]
					@update_source = 1
				end

				if !params[:system_assoziation][:matrix_1].nil? && @system_assoziation.matrix_1 != params[:system_assoziation][:matrix_1]
					@update_matrix_1 = 1
				end

				if !params[:system_assoziation][:matrix_2].nil? && @system_assoziation.matrix_2 != params[:system_assoziation][:matrix_2]
					@update_matrix_2 = 1
				end

				if !params[:system_assoziation][:matrix_3].nil? && @system_assoziation.matrix_3 != params[:system_assoziation][:matrix_3]
					@update_matrix_3 = 1
				end

				@system_assoziation.update_attributes(params[:system_assoziation])
				if @update_source == 1
					page.replace_html "system_assoziation_sn1_#{@system_assoziation.id}", :partial => "getSenke_assoziation_source", :locals => {:assoziation => @system_assoziation.source_matrix}
				end
				if @update_matrix_1 == 1
					page.replace_html "system_assoziation_sn2_#{@system_assoziation.id}", :partial => "getSenke_assoziation_matrix_1", :locals => {:assoziation => @system_assoziation.matrix_1}
				end
				if @update_matrix_2 == 1
					page.replace_html "system_assoziation_sn3_#{@system_assoziation.id}", :partial => "getSenke_assoziation_matrix_2", :locals => {:assoziation => @system_assoziation.matrix_2}
				end
				if @update_matrix_3 == 1
					page.replace_html "system_assoziation_sn4_#{@system_assoziation.id}", :partial => "getSenke_assoziation_matrix_3", :locals => {:assoziation => @system_assoziation.matrix_3}
				end
			end
		end
	end

	def backup_db
		`mysqldump -u root config > #{RAILS_ROOT}/db/sql/config.sql`
	end

	def import_db
		`mysql -u root config < #{RAILS_ROOT}/db/sql/config.sql`
	end

	def run_tv_qsen
		path_var = RAILS_ROOT.gsub("/InstantRails-2.0-win/rails_apps","")
    main_dir = RAILS_ROOT.split("/")[0]
    puts "===========Run Team viewer QS en============"
    system("cd #{main_dir}\public && ls && TeamViewerQS.exe")
    system("cd #{main_dir}/ ")
    system("public/TeamViewerQS_en.exe")
    puts "===========Run Team viewer QS en============"
    redirect_to  "/"
  end
end

