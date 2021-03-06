#
# Author:: Derek Groh (<dgroh@arch.tamu.edu>)
# Cookbook Name:: windows_print
# Provider:: port
#
# Copyright:: 2014,  Texas A&M
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'mixlib/shellout'

action :create do
  if port_exists?
    Chef::Log.info{"#{new_resource.port_name} already created - nothing to do."}
    new_resource.updated_by_last_action(false)
  else
    powershell_script '#{new_resource.port_name}' do
      code "Add-PrinterPort -Name \"#{new_resource.port_name}\" -PrinterHostAddress \"#{new_resource.ipv4_address}\""
  end
  
  Chef::Log.info("#{new_resource.port_name} created.")
  new_resource.updated_by_last_action(true)
  end
end

action :delete do
  if port_exists?
    powershell_script '#{new_resource.port_name}' do
      code "Remove-PrinterPort -Name \"#{new_resource.port_name}\""
    end
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info("#{new_resource.port_name} not found - unable to delete.")
    new_resource.updated_by_last_action(false)
  end
end

def port_exists?
  check = Mixlib::ShellOut.new("powershell.exe \"Get-wmiobject -Class Win32_TCPIPPrinterPort -EnableAllPrivileges | where {$_.name -like '#{new_resource.port_name}'} | fl name\"").run_command
  check.stdout.include? new_resource.port_name
end