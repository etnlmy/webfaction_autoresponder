require 'xmlrpc/client'
require 'net/imap'
require 'yaml'

module WebFaction
  class Endpoint
       
    # Initialize a new endpoint with the given combination username/email
    # Raises an exception if the user is not allowed to edit the email address or
    # if the email address is not a valid Webfaction address
    def initialize(username, email)
      @settings = YAML.load_file('./config/secrets.yml')
      @username = username
      @email = email
      raise "You are not allowed to edit the entered email address (#{@email})" unless user_can_edit_email?
    end


    def edit_autoresponder(args = {})
      @email_addresses = nil
      send({ "on" => :turn_on_autoresponder, "off" => :turn_off_autoresponder }[args["activate"]], args)
    end


    def turn_on_autoresponder(args = {})
      xmlrpc_client.call(
        "update_email",
        session_id,
        @email,
        @username,
        true,
        args["subject"] || "",
        args["body"] || "")  
    end


    def turn_off_autoresponder(args = {})
      xmlrpc_client.call(
        "update_email",
        session_id,
        @email,
        @username,
        false)
    end


    # Check that the provided IMAP username and password are valid
    def self.imap_credentials_valid?(username, password)
      imap = Net::IMAP.new('mail.webfaction.com', ssl: true)
      begin
        imap.login(username, password)
        credentials_valid = true
      rescue => e 
        if e.message =~ /Authentication failed/
          credentials_valid = false
        else  
          raise "Error during connection. Please try again later."     
        end
      ensure
        imap.logout
        imap.disconnect
      end
      credentials_valid
    end


    # Check if the IMAP user is authorized to edit the email address
    def user_can_edit_email?
      targets_for_address.include?(@username)
    end

    
    # Return an array of targets (addresses or mailboxes) for the email address
    def targets_for_address
      email_settings["targets"].split(",")
    end

    # Return a hash containing the current settings for the email address
    # The returned hash is as follows:
    # { "email_address" => "example@example.org",
    #   "id" => 127413,
    #   "targets" => <targets>,
    #   "autoresponder_from" => "",
    #   "autoresponder_on" => <0 or 1>,
    #   "autoresponder_message" => "",
    #   "autoresponder_subject" => ""
    # }
    def email_settings
      emails = email_addresses
      emails.select!{ |addr| addr["email_address"] == @email } 
      raise "The email address provided (#{@email}) does not exist" unless emails.any?
      emails.first
    end

    
    # Return an array of all the webfaction's email addresses
    def email_addresses
      begin
        @email_addresses ||= xmlrpc_client.call("list_emails", session_id)
      rescue Timeout::Error => e
        raise "Error during connection. Please try again later."     
      end
    end


    # Return a connection to the Webfaction XML-RCP API 
    def xmlrpc_client
      @xmlrpc_client ||= XMLRPC::Client.new2("https://api.webfaction.com/", nil, 5)
    end

    
    # Returns the session ID for the XML-RCP connection
    def session_id
      @session_id ||= initiate_xmlrpc_session
    end

    
    # Log into the XML-RCP API and return the session ID
    def initiate_xmlrpc_session
      begin
        response = xmlrpc_client.call("login", @settings["webfaction_user"], @settings["webfaction_password"])
        id = response.first
      rescue XMLRPC::FaultException, Timeout::Error => e
        raise "Error during connection. Please try again later."
      end
      id 
    end
    
  end
end