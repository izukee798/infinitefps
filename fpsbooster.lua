-- Base64 decode function
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function base64decode(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i - f%2^(i-1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c + (x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local memory = [[
LS0vLyBMb2FkIEZsdWVudCBVSQpsb2NhbCBGbHVlbnQgPSBsb2Fkc3RyaW5nKGdhbWU6SHR0cEdldCgiaHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2Rpc2NvYXJ0L0ZsdWVudFBsdXMvcmVmcy9oZWFkcy9tYWluL0JldGEubHVhIikpKCkKCmxvY2FsIFdpbmRvdyA9IEZsdWVudDpDcmVhdGVXaW5kb3coewogICAgVGl0bGUgPSAiS0lUS0FUIElORklOSVRFIEZQUyIsCiAgICBTdWJUaXRsZSA9ICIiLAogICAgVGFiV2lkdGggPSAxNjAsCiAgICBTaXplID0gVURpbTIuZnJvbU9mZnNldCg1MjAsIDM2MCksCiAgICBBY3J5bGljID0gdHJ1ZSwKICAgIFRoZW1lID0gIkRhcmsiLAogICAgTWluaW1pemVLZXkgPSBFbnVtLktleUNvZGUuTGVmdENvbnRyb2wKfSkKCgpsb2NhbCBDb25maWdzID0gIkZsdWVudFNjcmlwdEh1Yi9jcmFzaC1kZW1vIgpsb2NhbCBTYXZlTWFuYWdlciA9IEZsdWVudDpDcmVhdGVTYXZlTWFuYWdlcigpCmxvY2FsIEludGVyZmFjZU1hbmFnZXIgPSBGbHVlbnQ6Q3JlYXRlSW50ZXJmYWNlTWFuYWdlcigpClNhdmVNYW5hZ2VyOlNldExpYnJhcnkoRmx1ZW50KQpJbnRlcmZhY2VNYW5hZ2VyOlNldExpYnJhcnkoRmx1ZW50KQpTYXZlTWFuYWdlcjpJZ25vcmVUaGVtZVNldHRpbmdzKCkKU2F2ZU1hbmFnZXI6U2V0SWdub3JlSW5kZXhlcyh7fSkKU2F2ZU1hbmFnZXI6U2V0Rm9sZGVyKENvbmZpZ3MpCkludGVyZmFjZU1hbmFnZXI6U2V0Rm9sZGVyKENvbmZpZ3MpClNhdmVNYW5hZ2VyOkJ1aWxkQ29uZmlnU2VjdGlvbihXaW5kb3cpCkludGVyZmFjZU1hbmFnZXI6QnVpbGRJbnRlcmZhY2VTZWN0aW9uKFdpbmRvdykKCgpsb2NhbCBNYWluVGFiID0gV2luZG93OkFkZFRhYih7IFRpdGxlID0gIkZQUyIsIEljb24gPSAiRmxhbWUiIH0pCgoKTWFpblRhYjpBZGRCdXR0b24oewogICAgVGl0bGUgPSAiSU5GSU5JVEUgRlBTIFZFUlkgUkVBTCIsCiAgICBEZXNjcmlwdGlvbiA9ICIiLAogICAgQ2FsbGJhY2sgPSBmdW5jdGlvbigpCiAgICAgICAgd2hpbGUgdHJ1ZSBkbyBlbmQgCiAgICBlbmQKfSkKClNhdmVNYW5hZ2VyOkxvYWRBdXRvbG9hZENvbmZpZygpCgo=
]]

local tuff = base64decode(memory)
loadstring(tuff)()

warn("gay")
