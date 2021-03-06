module(..., package.seeall)

require"lfs"
require"cosmo"

REQUIRE_LUAROCKS = [[pcall(require, "luarocks.require")]]

WS_SCRIPT_TEMPLATE = [=[
require('sputnik.wsapi_app')
return sputnik.wsapi_app.new{
   VERSIUM_PARAMS = { [[$dir/wiki-data/]] },
   BASE_URL       = '/',
   NICE_URL       = '/', 
   PASSWORD_SALT  = '$password_salt',
   TOKEN_SALT     = '$token_salt',
}
]=]

CGI_TEMPLATE = [=[#! $dir/bin/lua
$require_luarocks
require('sputnik.wsapi_app')
local my_app = sputnik.wsapi_app.new{
   VERSIUM_PARAMS = { [[$dir/wiki-data/]] },
   BASE_URL       = '/cgi-bin/sputnik.cgi',
   PASSWORD_SALT  = '$password_salt',
   TOKEN_SALT     = '$token_salt',
}

require("wsapi.cgi")
wsapi.cgi.run(my_app)
]=]


CHARACTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local password_salt = ""
local token_salt = ""

function reset_salts()
   math.randomseed(os.time())
   password_salt = make_salt()
   token_salt = make_salt()
end

function make_salt(length)
   local buffer = ""
   local num_chars = CHARACTERS:len()
   local r
   for i=1, (length or 40) do
      r = math.random(num_chars)
      buffer = buffer..CHARACTERS:sub(r,r)
   end
   return buffer
end


function make_script(dir, subpath, template, options)

   options = options or {}

   dir = dir or lfs.currentdir()
   local path = dir.."/"..subpath

   if lfs.attributes(path) then
      print("Cannot create '"..path.."': file already exists.")
      print("Delete the file, then try again.")
      return
   end
   local out, err = io.open(path, "w")
   if err then
      print("Could not create file '"..path.."':")
      print(err)
      return
   end

   local require_luarocks = REQUIRE_LUAROCKS
   if options.without_luarocks then
      require_luarocks = ""
   end

   local content = cosmo.f(template){
                      dir           = dir, 
                      password_salt = password_salt,
                      token_salt    = token_salt,
                      require_luarocks = require_luarocks,
                   }
   out:write(content)
   out:close()
end

function make_wsapi_script(dir, subpath, options)
   make_script(dir, subpath, WS_SCRIPT_TEMPLATE, options)
end

function make_cgi_file(dir, subpath, options)
   make_script(dir, subpath, CGI_TEMPLATE, options)
end
