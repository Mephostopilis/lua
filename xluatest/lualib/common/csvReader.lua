local csvreader = {} --store function 
local csvcont = {}  --store csvcont

local function trim_left(s)  
    return string.gsub(s, "^%s+", "");  
end  
    
-- 去掉字符串右空白  
local function trim_right(s)  
    return string.gsub(s, "%s+$", "");  
end  
  
-- 解析一行  
function csvreader.parseline(line)  
    local ret = {};  
  
    local s = line .. ",";  -- 添加逗号,保证能得到最后一个字段  
  
    while (s ~= "") do  
        --print(0,s);  
        local v = "";  
        local tl = true;  
        local tr = true;  
  
        while(s ~= "" and string.find(s, "^,") == nil) do  
            --print(1,s);  
            if(string.find(s, "^\"")) then  
                local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");  
                --print(2,vx,vz);  
                if(vx == nil) then  
                    return nil;  -- 不完整的一行  
                end  
  
                -- 引号开头的不去空白  
                if(v == "") then  
                    tl = false;  
                end  
  
                v = v..vx;  
                s = vz;  
  
                --print(3,v,s);  
  
                while(string.find(s, "^\"")) do  
                    local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");  
                    --print(4,vx,vz);  
                    if(vx == nil) then  
                        return nil;  
                    end  
  
                    v = v.."\""..vx;  
                    s = vz;  
                    --print(5,v,s);  
                end  
  
                tr = true;  
            else  
                local _,_,vx,vz = string.find(s, "^(.-)([,\"].*)");  
                --print(6,vx,vz);  
                if(vx~=nil) then  
                    v = v..vx;  
                    s = vz;  
                else  
                    v = v..s;  
                    s = "";  
                end  
                --print(7,v,s);  
  
                tr = false;  
            end  
        end  
  
        if(tl) then v = trim_left(v); end  
        if(tr) then v = trim_right(v); end  
  
        ret[#ret+1] = v;  
        --print(8,"ret["..table.getn(ret).."]=".."\""..v.."\"");  
  		--print( v , string.len( v ) )
        if(string.find(s, "^,")) then  
            s = string.gsub(s,"^,", "");  
        end  
  
    end  
  
    return ret;  
end  
  
  
  
--解析csv文件的每一行  
function csvreader.getFileRowContent(file)  
    local content;  
  
    local check = false  
    local count = 0  
    while true do  
        local t = file:read()  
        if not t then  if count==0 then check = true end  break end  
  
        if not content then  
            content = t  
        else  
            content = content..t  
        end  
  
        local i = 1  
        while true do  
            local index = string.find(t, "\"", i)  
            if not index then break end  
            i = index + 1  
            count = count + 1  
        end  
  
        if count % 2 == 0 then check = true break end  
    end  
  
    if not check then  assert(1~=1) end  
    return content  
end  
  
  
  
--解析csv文件  
function csvreader.getfilecont( fileName )
	assert(type(fileName) == "string")
	fileName = fileName .. ".csv"
	local path = "./../cat/csv/" .. fileName
    local file = io.open(path, "r")  
    if file == nil then
    	file = io.open(path, "r")  
    end
    assert(file)  
    local title = parseline( getFileRowContent(file))
   --for k ,v in pairs( title ) do
    --	print("...............................................")
    --	print( k , v , string.len( v ) )
    --end

    local content = {}  
    while true do

        local line = getFileRowContent( file )   
        if not line then break end 
        local parasedline = parseline( line )

        local newline = {}
        --newline[title[i]] = parasedline[i]
       for i = 1 , #title do
        title[i] = string.gsub( title[i] , "^%s*(.-)%s*$" , "%1" )
        	newline[title[i]] = parasedline[i]
        --	print("****************************")
        --	print(title[i] , parasedline[i])
        end
         
        table.insert(content, newline)  
    end  
  
    file:close()  
		
    return content 
end  	
		
function csvreader.getStrRowContent( filecont )
	assert( filecont )  
		
	local content;  
		
    local check = false  
    local count = 0
		
    while true do  	
		local t = filecont
		print( t )
        if not content then  
            content = t  
        else  
            content = content..t  
        end  
		
        local i = 1  
        while true do  
            local index = string.find(t, "\"", i)  
            if not index then break end  
            i = index + 1  
            count = count + 1  
        end  
		
        if count % 2 == 0 then check = true break end  
		
		nFindStartIndex = nFindLastIndex + string.len("\r\n")
    end  
  
    if not check then  assert(1~=1) end  
    return content  
end  

return csvreader	
			
	
	
	
