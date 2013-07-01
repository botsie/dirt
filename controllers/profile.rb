#!/usr/bin/env ruby

include FileUtils::Verbose

module Dirt

  class ProfileController < Dirt::Controller
    def show(params)
      haml :profile
    end

    def edit(params)
      p '\n\n\n\n\nn\n\n'
      p session 
      p '\n\n\n\n\nn\n\n' 
      @error_msg = params[:error_msg]
      haml :profile_edit
    end

    def save(params)
      newname = ""
      if not params[:pic_file].nil?
        ext = {"image/png"=> ".png", "image/jpg" => ".jpg", "image/jpeg" => ".jpeg", "image/x-png" => ".png", "image/x-jpg" => ".jpg"}
        if not ext.keys.include?(params[:pic_file][:type])
           raise "File Type not supported"
        end
        tempfile = params[:pic_file][:tempfile]
        filename = params[:pic_file][:filename]
        newname = genRandom + ext[params[:pic_file][:type]]
        cp(tempfile.path, "./public/images/profile/pic/#{newname}")
      end
      team_name = params[:team_name]
      editor_type = params[:editor]=="1" ? true : false
      if team_name != session[:user][:team_name] || newname != "" || editor_type != session[:user][:editor]
        session[:user][:team_name] = team_name
        session[:user][:editor] = editor_type
        session[:user][:pic_url] = (newname == "" )? "default_profile.jpg" : newname
        Dirt::User.where(:uname => session[:user_id]).update(:pic_url => session[:user][:pic_url], :team_name => session[:user][:team_name], :editor => session[:user][:editor])
      end
    end
  end
end