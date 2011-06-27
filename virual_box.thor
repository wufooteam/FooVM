require "rubygems"
require "bundler/setup"

class VirtualBox < Thor

  @hostnames = ['wlocal.com']

  desc "ip VM_NAME", "get the IP for the provided VM name"

  def ip_address vm_name
    ip = `VBoxManage guestproperty enumerate #{vm_name} | grep "V4/IP" | cut -d"," -f2 | cut -d":" -f2 | tr -d " "`.chop
    puts "Current IP Address: #{ip}"
    ip
  end

  desc 'running? VM_NAME', 'boolean representing running state of vm'

  def running? vm_name
    val = (`VBoxManage showvminfo "#{vm_name}"`.match(/running/))
    ret = val.nil? ? false : true
    puts "VM is running: #{ret}"
    ret
  end

  desc 'stop VM_NAME', "saves the state of the currently running vm"

  def stop vm_name
    `VBoxManage controlvm #{vm_name} savestate`
  end

  desc 'start VM_NAME', 'starts the specified VM'

  def start vm_name
    `VBoxManage startvm "#{vm_name}"`
  end

  desc 'start_all VM_NAME', 'starts the VM and sets the hosts file'

  def start_all vm_name

    if !running? vm_name
      start vm_name
    end

    if ip = (ip_address vm_name)
      write_hosts ip
    else
      puts 'No host found!'
    end
  end

  desc "write_hosts", "sets /etc/hosts to IP address"

  def write_hosts ip
    all_subdomains.each do |subdomain|
      all_tlds.each do |tld|
        if subdomain == ''
          host = "wlocal.#{tld}"
        else
          host = "#{subdomain}.wlocal.#{tld}"
        end
        write_host host, ip
        puts "assigned '#{ip}' to host name '#{host}'"
      end


    end
  end

  desc "write_host HOST_NAME IP", "uses ghost to write an individual host name"

  def write_host host_name, ip
    `ghost modify #{host_name} #{ip}`
  end

  desc "all_subdomains", "the list of all hosts to write to /etc/hosts"

  def all_subdomains
    arr = ['', 'master', 'test', 'gallary']
    puts "All hosts: #{arr}"
    arr
  end

  desc "all_tlds", "the list of all tlds we offer"

  def all_tlds
    arr = ['com', 'mx', 'eu']
    puts "All tlds: #{arr}"
    arr
  end


end