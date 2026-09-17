-- Fawn Modern | Canonical Serotonin build
local Fawn={
    ProductName="Fawn Modern",
    DisplayName="Fawn Modern",
    IsFawnLibrary=true,
    IsModular=true,
    Namespace="FawnModern",
}
Fawn.Performance={Mode="Peak",FastDraw=false,SmartKeyPolling=true,SnowParticles=48,ImageRetryMs=5000,FrameNow=nil,FrameDt=nil,ScreenW=1920,ScreenH=1080,ScreenReady=false,RGB={},RGBCount=0,Fit={},FitCount=0,KeyWatch={}}

if type(draw)~="table" or type(Color3)~="table" then error("Fawn Modern: Serotonin draw and Color3 APIs are required") end
if type(utility)~="table" or type(mouse)~="table" or type(keyboard)~="table" then error("Fawn Modern: Serotonin utility, mouse and keyboard APIs are required") end
if type(cheat)~="table" or type(cheat.Register)~="function" then error("Fawn Modern: cheat.Register is required") end

local floor,ceil,abs,min,max,sin,cos,pi=math.floor,math.ceil,math.abs,math.min,math.max,math.sin,math.cos,math.pi
local insert,remove,concat,sort=table.insert,table.remove,table.concat,table.sort
local lower,upper,sub,find,format=string.lower,string.upper,string.sub,string.find,string.format
local unpack=unpack or table.unpack
local loadfn=loadstring or load

local function clamp(v,a,b) v=tonumber(v)or a
if v<a then return a elseif v>b then return b end return v end
local function round(v)return floor((tonumber(v)or 0)+.5)end
local function copy(v,seen)
    if type(v)~="table"then return v end
    seen=seen or{}
if seen[v]then return seen[v]end
    local n={}
seen[v]=n
for k,x in pairs(v)do n[copy(k,seen)]=copy(x,seen)end
return n
end
local function arr(t)local n={}for i,v in ipairs(type(t)=="table"and t or{})do n[i]=v end return n end
local function removeValue(t,v)for i=#t,1,-1 do if t[i]==v then remove(t,i)return true end end return false end
local function indexOf(t,v)for i,x in ipairs(t or{})do if x==v then return i end end end
local function nowMs()
    local q=Fawn.Performance.FrameNow;if q~=nil then return q end
    local ok,v=pcall(utility.GetTickCount);return ok and tonumber(v)or 0
end
local function dt()
    local q=Fawn.Performance.FrameDt;if q~=nil then return q end
    local ok,v=pcall(utility.GetDeltaTime);return ok and tonumber(v)or(1/60)
end
local function screenSize()
    local P=Fawn.Performance
    if P.ScreenReady then return P.ScreenW,P.ScreenH end
    local ok,w,h=pcall(draw.GetScreenSize)
    if ok and type(w)=="number"and type(h)=="number"then P.ScreenW,P.ScreenH,P.ScreenReady=w,h,true;return w,h end
    return P.ScreenW,P.ScreenH
end
local function rgb(c)
    local r,g,b=255,255,255
    if type(c)=="table"then r=clamp(round(c[1]or c.r or 255),0,255);g=clamp(round(c[2]or c.g or 255),0,255);b=clamp(round(c[3]or c.b or 255),0,255)end
    local key=r*65536+g*256+b;local P=Fawn.Performance;local out=P.RGB[key]
    if out then return out end
    out=Color3.fromRGB(r,g,b);P.RGB[key]=out;P.RGBCount=P.RGBCount+1
    if P.RGBCount>2048 then P.RGB={[key]=out};P.RGBCount=1 end
    return out
end
local function rgba(v,default)
    local d=default or{255,255,255,255}
if type(v)~="table"then return copy(d)end
    return{clamp(round(v[1]or v.r or d[1]),0,255),clamp(round(v[2]or v.g or d[2]),0,255),clamp(round(v[3]or v.b or d[3]),0,255),clamp(round(v[4]or v.a or d[4]or 255),0,255)}
end
local function blend(a,b,t)
    t=clamp(t,0,1)
local q={}
    for i=1,4 do q[i]=round((a[i]or 255)+((b[i]or 255)-(a[i]or 255))*t)end
    return q
end
local function resolve(v,...)if type(v)=="function"then local ok,r=pcall(v,...)
if ok then return r end return nil end return v end

local REF={
    Width=1300,Height=985,Sidebar=275,ContentX=293,ContentTop=110,RightMargin=32,ColumnGap=18,SectionGap=33,
    Top=20,TopH=50,ProfileH=55,ProfileBottom=15,ProfileLineGap=14,
    Full={rowH=63,font=20,ctrlW=219,ddH=40,ddR=10,ddFont=19,ddPadL=10,ddPadR=12,chev=16,togW=55,togH=28,knob=24,sKnob=22,sGap=17,valH=34,valPad=13,valFont=16,valR=8,keyH=40,keyMin=96,keyMax=160,keyPad=12,keyFont=17,keyR=10,sw=40,swR=10,dots=16,dotsGap=20,itemH=39,itemFont=17,itemPad=10,itemR=7,padL=22,padR=23},
    Compact={rowH=48,font=16,ctrlW=150,ddH=34,ddR=8,ddFont=15,ddPadL=9,ddPadR=9,chev=14,togW=44,togH=24,knob=20,sKnob=16,sGap=10,valH=28,valPad=9,valFont=14,valR=6,keyH=34,keyMin=80,keyMax=140,keyPad=10,keyFont=15,keyR=8,sw=34,swR=8,dots=14,dotsGap=14,itemH=32,itemFont=14,itemPad=8,itemR=6,padL=14,padR=14}
}

Fawn.Style={
    Font="Verdana",ReferenceWidth=REF.Width,ReferenceHeight=REF.Height,SidebarWidth=REF.Sidebar,
    RowHeight=REF.Full.rowH,ControlHeight=REF.Full.ddH,ControlWidth=REF.Full.ctrlW,
    NoFakeShadows=true,SolidOutline=true,ReferenceBased=true,ThreeDotKeybindMenu=true,CaretPeriodMs=900
}
Fawn.Rules={
    DropdownIndexBase=1,MultiSelectReturnsValues=true,InputReturnsString=true,ColorFormat="RGBA array",
    SliderRangeIsVisualUnlessClamp=true,AutoSectionsExpand=true,FixedFillSectionsOwnOverflow=true,
    NestedWheelOwnership=true,DestroyedObjectsAreTerminal=true,PopupsStayInsideWindow=true,
    UIscaleIndependentFromResize=true
}
Fawn.Spacing={WindowLeft=REF.ContentX,WindowRight=REF.RightMargin,ColumnGap=REF.ColumnGap,SectionGap=REF.SectionGap,Row=REF.Full.rowH,RowPadLeft=REF.Full.padL,RowPadRight=REF.Full.padR}
Fawn.OverlaySpacing={Padding=14,Header=40,Row=32,Gap=8}
Fawn.HeaderSpacing={Sidebar=REF.Sidebar,Top=REF.Top,Height=REF.TopH,ContentTop=REF.ContentTop}
Fawn.ControlMetrics={Row=REF.Full.rowH,FieldHeight=REF.Full.ddH,FieldWidth=REF.Full.ctrlW,DropdownPaddingLeft=REF.Full.ddPadL,DropdownPaddingRight=REF.Full.ddPadR,ToggleWidth=REF.Full.togW,ToggleHeight=REF.Full.togH,ColorSize=REF.Full.sw}
Fawn.KeybindMetrics={MinWidth=REF.Full.keyMin,MaxWidth=REF.Full.keyMax,Height=REF.Full.keyH,Padding=REF.Full.keyPad,Dots=REF.Full.dots,DotsGap=REF.Full.dotsGap}
Fawn.NotificationPositions={"Top Left","Top Right","Bottom Left","Bottom Right"}

local function theme(base,over)
    local t=copy(base or{})
for k,v in pairs(over or{})do t[k]=copy(v)end
return t
end
local MODERN={
    font="Verdana",menuBg={15,16,20,255},card={22,23,28,255},rowHover={28,29,35,255},control={37,39,46,255},controlHover={45,47,55,255},text={227,228,232,255},navText={200,202,208,255},muted={139,141,149,255},icon={154,156,164,255},chev={213,214,218,255},accent={63,126,247,255},white={255,255,255,255},black={0,0,0,255},toggleTrack={13,14,18,255},toggleKnob={227,228,232,255},logoBg={255,255,255,255},logoFg={20,22,51,255},activeItem={34,36,42,255},popup={30,32,38,255},danger={224,107,107,255},success={93,190,115,255},warning={235,183,76,255},avatar={179,37,44,255},avatarDark={42,20,22,255},outline={55,58,68,255},line={255,255,255,18}
}
local PRESETS={
    ["Modern Blue"]=MODERN,
    Neverlose=MODERN,Fawn=MODERN,
    Midnight=theme(MODERN,{menuBg={9,11,17,255},card={15,18,26,255},control={25,30,42,255},controlHover={34,40,55,255},activeItem={22,28,39,255},popup={20,24,34,255},outline={39,47,64,255},accent={72,128,255,255}}),
    Graphite=theme(MODERN,{menuBg={17,17,18,255},card={24,24,26,255},control={39,39,43,255},controlHover={48,48,53,255},activeItem={34,34,38,255},popup={31,31,35,255},outline={61,61,67,255},accent={145,151,164,255}}),
    Amethyst=theme(MODERN,{accent={150,93,245,255},activeItem={39,31,52,255},outline={64,49,86,255},logoFg={49,25,82,255}}),
    Rose=theme(MODERN,{accent={232,101,151,255},activeItem={50,31,40,255},outline={82,48,62,255},logoFg={85,25,48,255}}),
    Sakura=theme(MODERN,{accent={245,148,184,255},activeItem={49,34,42,255},outline={77,54,65,255},logoFg={84,35,55,255}}),
    Emerald=theme(MODERN,{accent={66,191,129,255},activeItem={26,45,38,255},outline={43,75,62,255},logoFg={21,74,50,255}}),
    Teal=theme(MODERN,{accent={56,190,198,255},activeItem={25,43,46,255},outline={42,72,76,255},logoFg={17,71,75,255}}),
    Amber=theme(MODERN,{accent={230,164,65,255},activeItem={49,40,25,255},outline={79,64,39,255},logoFg={85,55,13,255}}),
    Crimson=theme(MODERN,{accent={218,76,83,255},activeItem={49,28,31,255},outline={79,44,49,255},logoFg={87,20,25,255}}),
    Arctic=theme(MODERN,{menuBg={16,19,23,255},card={23,28,34,255},control={35,43,52,255},controlHover={43,53,64,255},accent={102,189,255,255},outline={55,72,86,255},activeItem={30,40,49,255}}),
    Monochrome=theme(MODERN,{accent={226,228,232,255},logoFg={25,26,29,255},activeItem={39,40,44,255},outline={70,71,77,255}}),
    ["Fawn Gold"]=theme(MODERN,{accent={226,199,153,255},activeItem={47,42,33,255},outline={75,66,52,255},logoFg={78,58,24,255}})
}
Fawn.ThemeNames={"Modern Blue","Midnight","Graphite","Amethyst","Rose","Sakura","Emerald","Teal","Amber","Crimson","Arctic","Monochrome","Fawn Gold"}
Fawn.Presets=PRESETS

local E={windows={},overlays={},notifications={},paintCount=0,paintErrors=0,lastPaintError=nil,drawErrors=0,lastDrawError=nil,colorClipboard={255,255,255,255},notificationPosition="Bottom Right",nextId=0}
Fawn.Performance.KeyWatchProvider=function()
    for _,w in ipairs(E.windows)do if w and not w.destroyed and w.captureBind then return POLL end end
    local out=Fawn.Performance.KeyWatch;for i=#out,1,-1 do out[i]=nil end;local seen={}
    local function add(k)if k~=nil then k=tostring(k);if k~=""and not seen[k]then seen[k]=true;out[#out+1]=k end end end
    for _,w in ipairs(E.windows)do if w and not w.destroyed then add(w.toggleKey);if w.toggleControl then add(w.toggleControl.key)end end end
    if #out==0 then out[1]="Insert"end
    return out
end

local function safeDraw(name,...)
    local fn=draw[name]
    if type(fn)~="function"then return false end
    -- Never call the native renderer naked. A bad native argument must become a
    -- recoverable draw error instead of taking Serotonin down with the script.
    local ok,err=pcall(fn,...)
    if not ok then E.drawErrors=E.drawErrors+1;E.lastDrawError=tostring(err)end
    return ok
end
local function rect(x,y,w,h,c,r,a)if w<=0 or h<=0 then return end
safeDraw("RectFilled",floor(x),floor(y),max(1,floor(w+.5)),max(1,floor(h+.5)),rgb(c),max(0,tonumber(r)or 0),a==nil and(c[4]or 255)or a)end
local function outline(x,y,w,h,c,r,a,t)if w<=0 or h<=0 then return end
safeDraw("Rect",floor(x),floor(y),max(1,floor(w+.5)),max(1,floor(h+.5)),rgb(c),tonumber(t)or 1,max(0,tonumber(r)or 0),a==nil and(c[4]or 255)or a)end
local function line(x1,y1,x2,y2,c,t,a)safeDraw("Line",x1,y1,x2,y2,rgb(c),tonumber(t)or 1,a==nil and(c[4]or 255)or a)end
local function circle(x,y,r,c,a)safeDraw("CircleFilled",x,y,max(0,r),rgb(c),32,a==nil and(c[4]or 255)or a)end

local BASE_FONT_H=nil
local measureCache={}
local measureCount=0
local function measure(textValue,size,fontName)
    local t=tostring(textValue or"")
local f=fontName or"Verdana"
local sz=max(1,floor((tonumber(size)or 15)+.5))
local key=f.."\1"..sz.."\1"..t
local q=measureCache[key]
if q then return q[1],q[2]end
    if not BASE_FONT_H then local ok,w,h=pcall(draw.GetTextSize,"Ag",f)
BASE_FONT_H=(ok and type(h)=="number"and h>0)and h or 13 end
    local ok,w,h=pcall(draw.GetTextSize,t,f)
if not ok or type(w)~="number"then w,h=#t*BASE_FONT_H*.55,BASE_FONT_H end
    local k=sz/(h and h>0 and h or BASE_FONT_H)
local outW=w*k
local outH=(h or BASE_FONT_H)*k
    measureCount=measureCount+1
if measureCount>5000 then measureCache={}
measureCount=0 end
measureCache[key]={outW,outH}
return outW,outH
end
local function text(t,x,y,c,size,fontName,a)
    t=tostring(t or"");if t==""then return end
    local fn=draw.Text or draw.text;if type(fn)~="function"then return end
    local tx,ty,col,font,alpha,fs=floor(x),floor(y),rgb(c),fontName or"Verdana",a==nil and(c[4]or 255)or a,floor((tonumber(size)or 15)+.5)
    -- Text is also protected. This keeps a runtime-specific text signature
    -- mismatch from becoming a native crash on the first paint frame.
    local ok,err=pcall(fn,t,tx,ty,col,font,alpha,fs)
    if not ok then E.drawErrors=E.drawErrors+1;E.lastDrawError=tostring(err)end
end
local function textC(t,x,cy,c,size,fontName,a)local _,h=measure(t,size,fontName)
text(t,x,cy-h*.5,c,size,fontName,a)end
local function renderedFontSize(size)return max(1,floor((tonumber(size)or 15)+.5))end
local function caretWidth(t,size,fontName)
    return measure(t or"",renderedFontSize(size),fontName or"Verdana")
end
local function caretLine(x,cy,shown,size,fontName,c,a)
    local fs=renderedFontSize(size)
    local sample=(shown and shown~="")and shown or"Ag"
    local _,h=measure(sample,size,fontName or"Verdana")
    local tx=floor(x+.5)
    local ty=floor(cy-h*.5)
    local th=max(fs,ceil(h))
    line(tx,ty+1,tx,ty+th-1,c,max(1,floor((fs/14)+.5)),a or 255)
end
local function fit(t,maxW,size,fontName)
    t=tostring(t or"");if maxW<=0 then return""end
    local fs=max(1,floor((tonumber(size)or 15)+.5));local mw=max(0,floor(maxW+.5));local f=fontName or"Verdana";local P=Fawn.Performance
    local ck=f.."\1"..fs.."\1"..mw.."\1"..t;local cached=P.Fit[ck];if cached~=nil then return cached end
    local out
    if measure(t,fs,f)<=mw then out=t else
        local ell="...";local ew=measure(ell,fs,f)
        if ew>mw then out="" else local lo,hi=0,#t;while lo<hi do local m=ceil((lo+hi)/2);if measure(sub(t,1,m),fs,f)+ew<=mw then lo=m else hi=m-1 end end;out=sub(t,1,lo)..ell end
    end
    P.Fit[ck]=out;P.FitCount=P.FitCount+1;if P.FitCount>4096 then P.Fit={[ck]=out};P.FitCount=1 end
    return out
end
local function wrapText(t,maxW,size,fontName,maxLines)
    t=tostring(t or"")
maxW=max(1,tonumber(maxW)or 1)
maxLines=maxLines and max(1,floor(maxLines))or 999
    local lines={}
for para in (t.."\n"):gmatch("(.-)\n")do
        if para==""then lines[#lines+1]="" else
            local cur=""
for word in para:gmatch("%S+")do
                local trial=cur==""and word or(cur.." "..word)
                if measure(trial,size,fontName)<=maxW then cur=trial else
                    if cur~=""then lines[#lines+1]=cur end
                    if measure(word,size,fontName)<=maxW then cur=word else
                        local chunk=""
for i=1,#word do local tr=chunk..sub(word,i,i)
if measure(tr,size,fontName)>maxW and chunk~=""then lines[#lines+1]=chunk
chunk=sub(word,i,i)else chunk=tr end end
cur=chunk
                    end
                end
                if #lines>=maxLines then break end
            end
            if #lines<maxLines and cur~=""then lines[#lines+1]=cur end
        end
        if #lines>=maxLines then break end
    end
    if #lines>maxLines then while #lines>maxLines do remove(lines)end end
    if #lines==maxLines and concat(lines," ")~=t:gsub("\n"," ")then lines[#lines]=fit(lines[#lines],maxW-measure("...",size,fontName),size,fontName).."..."end
    return lines
end

local function alphaFor(window,role,base)
    if not window or not window.liquidGlass then return base or 255 end
    local root=clamp(round((window.glassOpacity or .72)*255),45,245)
    local delta={main=0,sidebar=4,card=12,control=28,popup=34,overlay=20,outline=65}
    return clamp(root+(delta[role]or 0),0,255)
end
local function glassColor(window,role,c)
    if not window or not window.liquidGlass then return c end
    local main=window.theme.menuBg or MODERN.menuBg
    if role=="card"then return blend(main,c,.30)elseif role=="control"then return blend(main,c,.52)elseif role=="popup"then return blend(main,c,.48)elseif role=="sidebar"then return blend(main,c,.18)end
    return c
end

local Input={mx=-1,my=-1,left=false,right=false,click=false,rightClick=false,released=false,rightReleased=false,wheel=0,keys={},pressed={},releasedKeys={},chars={},updated=0,_clickQ=false,_rightClickQ=false,_releaseQ=false,_rightReleaseQ=false,_wheelQ=0,_pressedQ={},_releasedKeysQ={}}
local KEYMAP={Space=0x20,Backspace=0x08,Enter=0x0D,Escape=0x1B,Tab=0x09,Shift=0x10,Ctrl=0x11,Alt=0x12,Insert=0x2D,Delete=0x2E,Home=0x24,End=0x23,Up=0x26,Down=0x28,Left=0x25,Right=0x27,["."]=0xBE,["-"]=0xBD}
local POLL={}
do local s="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"for i=1,#s do POLL[#POLL+1]=sub(s,i,i)end
for _,k in ipairs{"Space","Backspace","Enter","Escape","Tab","Shift","Ctrl","Alt","Insert","Delete","Home","End","Up","Down","Left","Right","Mouse1","Mouse2","Mouse3","Mouse4","Mouse5","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"}do POLL[#POLL+1]=k end end
local function keyState(k)local ok,v=pcall(keyboard.IsPressed,k)
return ok and v==true end
local function nativeKey(name)
    if sub(name,1,5)=="Mouse"then local n=tonumber(sub(name,6))or 0
if n==1 then return keyState(1)elseif n==2 then return keyState(2)elseif n==3 then return keyState(4)elseif n==4 then return keyState(5)elseif n==5 then return keyState(6)end end
    local k=KEYMAP[name]
if not k and type(name)=="string"then if #name==1 then local b=string.byte(upper(name))
if b and((b>=48 and b<=57)or(b>=65 and b<=90))then k=b end else local fn=tonumber(name:match("^F(%d+)$"))
if fn and fn>=1 and fn<=12 then k=0x6F+fn end end end
    return keyState(k or name)
end
local function mouseDown(which)
    local names=which==1 and{"left","leftmouse",1}or{"right","rightmouse",2}
    if type(mouse.IsPressed)=="function"then for _,n in ipairs(names)do local ok,v=pcall(mouse.IsPressed,n)
if ok and v==true then return true end end end
    local keys=which==1 and{1,"leftmouse","lbutton","mouse1"}or{2,"rightmouse","rbutton","mouse2"}
    for _,n in ipairs(keys)do if keyState(n)then return true end end
    return false
end
local function mouseClicked(which)
    if type(mouse.IsClicked)~="function"then return false end
    local names=which==1 and{"left","leftmouse",1}or{"right","rightmouse",2}
    for _,n in ipairs(names)do local ok,v=pcall(mouse.IsClicked,n)
if ok and v==true then return true end end
    return false
end
local WHEEL_UP={"wheelup","wheel_up","mousewheelup","mwheelup","scrollup"}
local WHEEL_DOWN={"wheeldown","wheel_down","mousewheeldown","mwheeldown","scrolldown"}
local function wheelStep()
    for _,name in ipairs{"GetWheelDelta","getWheelDelta","get_wheel_delta","WheelDelta","wheelDelta","GetScrollDelta","getScrollDelta","get_scroll_delta"}do local f=mouse[name]
if type(f)=="function"then local ok,v=pcall(f)
if ok and type(v)=="number"and v~=0 then return v>0 and-1 or 1 end end end
    for _,n in ipairs(WHEEL_UP)do local hit=false;if type(mouse.IsClicked)=="function"then local ok,v=pcall(mouse.IsClicked,n);hit=ok and v==true end;if hit or keyState(n)then return-1 end end
    for _,n in ipairs(WHEEL_DOWN)do local hit=false;if type(mouse.IsClicked)=="function"then local ok,v=pcall(mouse.IsClicked,n);hit=ok and v==true end;if hit or keyState(n)then return 1 end end
    return 0
end
local prevLeft,prevRight=false,false
local prevKeys={}
local function pollInput()
    local P=Fawn.Performance;local okT,vT=pcall(utility.GetTickCount);if okT then P.FrameNow=tonumber(vT)or P.FrameNow end;local okD,vD=pcall(utility.GetDeltaTime);if okD then P.FrameDt=tonumber(vD)or P.FrameDt end
    local ok,p=pcall(utility.GetMousePos)
if ok and type(p)=="table"then Input.mx=tonumber(p[1])or Input.mx
Input.my=tonumber(p[2])or Input.my end
    local l=mouseDown(1)
local r=mouseDown(2)
    if mouseClicked(1)or(l and not prevLeft)then Input._clickQ=true end
if prevLeft and not l then Input._releaseQ=true end
if mouseClicked(2)or(r and not prevRight)then Input._rightClickQ=true end
if prevRight and not r then Input._rightReleaseQ=true end
    Input.left,Input.right=l,r
prevLeft,prevRight=l,r
Input._wheelQ=Input._wheelQ+wheelStep()
    local nextKeys={};local provider=Fawn.Performance.KeyWatchProvider;local watch=(Fawn.Performance.SmartKeyPolling and type(provider)=="function"and provider())or POLL
for _,k in ipairs(watch)do local cur=nativeKey(k)
nextKeys[k]=cur
if cur and not prevKeys[k]then Input._pressedQ[k]=true end
if prevKeys[k]and not cur then Input._releasedKeysQ[k]=true end end
    Input.keys=nextKeys
prevKeys=nextKeys
Input.updated=Input.updated+1
end
local function beginPaintInput()
    Input.click,Input.rightClick,Input.released,Input.rightReleased=Input._clickQ,Input._rightClickQ,Input._releaseQ,Input._rightReleaseQ
    Input.wheel=Input._wheelQ
Input.pressed,Input.releasedKeys=Input._pressedQ,Input._releasedKeysQ
    Input._clickQ,Input._rightClickQ,Input._releaseQ,Input._rightReleaseQ=false,false,false,false
Input._wheelQ=0
Input._pressedQ,Input._releasedKeysQ={},{}
end

local CHAR_KEYS={}
for i=65,90 do CHAR_KEYS[#CHAR_KEYS+1]={"k"..i,i,string.char(i+32),string.char(i)}end
local nums={")","!","@","#","$","%","^","&","*","("}
for i=0,9 do CHAR_KEYS[#CHAR_KEYS+1]={"n"..i,48+i,tostring(i),nums[i+1]}end
for _,q in ipairs{{"p186",186,";",":"},{"p187",187,"=","+"},{"p188",188,",","<"},{"p189",189,"-","_"},{"p190",190,".",">"},{"p191",191,"/","?"},{"p192",192,"`","~"},{"p219",219,"[","{"},{"p220",220,"\\","|"},{"p221",221,"]","}"},{"p222",222,"'",'"'},{"space",32," "," "}}do CHAR_KEYS[#CHAR_KEYS+1]=q end
local function anyKey(...)for i=1,select("#",...)do local k=select(i,...)
if k~=nil and keyState(k)then return true end end return false end
local function repeater(state,id,down,delay,rate)
    local st=state[id]or{down=false,next=0}
state[id]=st
local n=nowMs()
if down then if not st.down then st.down=true
st.next=n+(delay or 430)
return true elseif n>=st.next then st.next=n+(rate or 50)
return true end else st.down=false
st.next=0 end
return false
end

local Control,Section,Tab,Window,Overlay,Watermark,KeybindList,InfoPanel,ESPPreview,Notification={},{},{},{},{},{},{},{},{},{}
for _,c in ipairs{Control,Section,Tab,Window,Overlay,Watermark,KeybindList,InfoPanel,ESPPreview,Notification}do c.__index=c end

local function kind(o)return type(o)=="table"and o.kind or nil end
local function newId(prefix)E.nextId=E.nextId+1
return(prefix or"fawn").."_"..E.nextId end
local function alive(o)return type(o)=="table"and not o.destroyed end

local function visibilityPass(o)
    local r=o and o.visibilityRule
if not r then return o and o.visible~=false end
    local src=r.source
if not alive(src)then return o.visible~=false end
    local v=src.Get and src:Get()or nil
local match=false
    if type(r.expected)=="function"then local ok,q=pcall(r.expected,v,src,o)
match=ok and q==true
    elseif type(r.expected)=="table"then for _,x in pairs(r.expected)do if type(v)=="table"then for _,y in ipairs(v)do if y==x then match=true break end end elseif v==x then match=true end
if match then break end end
    elseif type(v)=="table"then for _,y in ipairs(v)do if y==r.expected then match=true break end end
    else match=v==r.expected end
    return r.invert and not match or match
end
local function setRule(o,source,expected,invert)o.visibilityRule={source=source,expected=expected,invert=invert==true}
return o end

local function themeOf(o)
    local w=o
if kind(o)~="Window"and kind(o)~="Panel"then w=o.window or(o.parent and o.parent.window)end
    return(w and w.theme)or PRESETS["Modern Blue"]
end
local function getOptionIndex(c,v)
    if type(v)=="number"then local i=floor(v)
if i>=1 and i<=#(c.options or{})then return i end end
    for i,x in ipairs(c.options or{})do if x==v or tostring(x)==tostring(v)then return i end end
end
local function controlCallback(c,silent)
    if not silent and type(c.callback)=="function"then local ok=pcall(c.callback,c:Get(),c)
if not ok then end end
end

function Control:Get()
    if self.type=="dropdown"then return self.options[self.value]
    elseif self.type=="multiselect"then local n={}for i,v in ipairs(self.options)do if self.value[i]then n[#n+1]=v end end return n
    elseif self.type=="input"then return tostring(self.value or"")
    elseif self.type=="keybind"then return self.active==true
    elseif self.type=="value"then return resolve(self.valueSource,self)
    end
    return self.value
end
function Control:GetRaw()if self.type=="multiselect"then return arr(self.value)elseif self.type=="input"then return tostring(self.value or"")end return self.value end
function Control:GetIndex()return self.type=="dropdown"and self.value or nil end
function Control:GetKey()return self.type=="keybind"and self.key or(self.keybind and self.keybind.key)end
function Control:GetMode()local k=self.type=="keybind"and self or self.keybind
return k and k.mode or nil end
function Control:IsActive()local k=self.type=="keybind"and self or self.keybind
return k and k.active==true or false end
function Control:OnChanged(fn)self.callback=type(fn)=="function"and fn or nil
return self end
function Control:SetVisible(v)self.visible=v~=false
return self end
function Control:SetDisabled(v)self.disabled=v==true
return self end
function Control:SetText(v)self.label=tostring(v or"")
return self end
function Control:SetFlag(v)
    local w=self.window
if self.flag and w then w.flags[self.flag]=nil end
self.flag=v and tostring(v)or nil
if self.flag and w then w.flags[self.flag]=self end
return self
end
function Control:GetFlag()return self.flag end
function Control:SetClamp(v)if self.type=="slider"then self.clampValue=v==true
if self.clampValue then self:Set(self.value,true)end end return self end
function Control:GetClamp()return self.type=="slider"and self.clampValue==true or false end
function Control:SetRange(lo,hi)if self.type=="slider"then lo,hi=tonumber(lo),tonumber(hi)
if lo and hi then if lo>hi then lo,hi=hi,lo end
self.min,self.max=lo,hi
if self.clampValue then self:Set(self.value,true)end end end return self end
function Control:GetRange()if self.type=="slider"then return self.min,self.max end end
function Control:Set(v,silent)
    if self.destroyed then return self end
    local old=self:GetRaw()
    if self.type=="toggle"then self.value=v==true
    elseif self.type=="slider"then local n=tonumber(v)
if n==nil then return self end
if self.clampValue then n=clamp(n,self.min,self.max)end
if not self.float then n=round(n)end
self.value=n
    elseif self.type=="dropdown"then local i=getOptionIndex(self,v)
if not i then return self end
self.value=i
    elseif self.type=="multiselect"then
        local n={}for i=1,#self.options do n[i]=false end
        if type(v)=="table"then local bool=false
for i=1,#self.options do if type(v[i])=="boolean"then bool=true break end end
if bool then for i=1,#self.options do n[i]=v[i]==true end else for k,x in pairs(v)do if type(k)=="string"and x==true then local i=getOptionIndex(self,k)
if i then n[i]=true end elseif type(k)=="number"then local i=getOptionIndex(self,x)
if i then n[i]=true end end end end
        elseif v~=nil then local i=getOptionIndex(self,v)
if i then n[i]=true end end
self.value=n
    elseif self.type=="input"then
        local q=tostring(v==nil and""or v)
if self.maxLength and self.maxLength>0 and#q>self.maxLength then q=sub(q,1,self.maxLength)end
        if self.numeric then local out,dot,minus="",false,false
for i=1,#q do local ch=sub(q,i,i)
if ch:match("%d")then out=out..ch elseif ch=="."and self.allowFloat~=false and not dot then dot=true
out=out..ch elseif ch=="-"and self.allowNegative~=false and not minus and#out==0 then minus=true
out=out..ch end end
q=out end
self.value=q
    elseif self.type=="color"then self.value=rgba(v,self.value or{255,255,255,255})
    elseif self.type=="keybind"then return self:SetKey(v)
    elseif self.type=="label"then self.label=tostring(v or"")
self.value=self.label
return self
    elseif self.type=="value"then self.valueSource=v
return self
    else self.value=v end
    local changed=tostring(old)~=tostring(self:GetRaw())
if self.type=="multiselect"or self.type=="color"then changed=true end
if changed then controlCallback(self,silent)end
return self
end
function Control:SetMode(mode)
    local k=self.type=="keybind"and self or self.keybind
if not k then return self end
mode=tostring(mode or"")
if mode~="Hold"and mode~="Toggle"and mode~="Always"then return self end
k.mode=mode
k.active=mode=="Always"
k.last=false
if k.callback then pcall(k.callback,k.active,k)end
return self
end
function Control:SetKey(key,label)
    local k=self.type=="keybind"and self or self.keybind
if not k then return self end
k.key=key
k.keyLabel=label or(key and tostring(key):upper()or"None")
k.active=k.mode=="Always"
k.last=false
if k.onKeyChanged then pcall(k.onKeyChanged,k.key,k.keyLabel,k)end
return self
end
function Control:ClearKey()return self:SetKey(nil,"None")end
function Control:IsKeyCleared()local k=self.type=="keybind"and self or self.keybind
return not k or k.key==nil or k.key=="" end
function Control:OnKeyChanged(fn)local k=self.type=="keybind"and self or self.keybind
if k then k.onKeyChanged=fn end
return self end
function Control:SetListVisible(v)local k=self.type=="keybind"and self or self.keybind
if k then k.keybindList=v~=false end
return self end
function Control:GetKeybind()return self.keybind end
function Control:SetKeybind(key,opt)
    opt=type(opt)=="table"and opt or{}
if not self.keybind then self.keybind=setmetatable({kind="Control",type="keybind",label=self.label,key=key,keyLabel=opt.label or(key and tostring(key):upper()or"None"),mode=opt.mode or"Hold",active=(opt.mode=="Always"),keyboardOnly=opt.keyboardOnly==true,keybindList=opt.keybindList~=false,parentControl=self,section=self.section,window=self.window,visible=true},Control)else self.keybind:SetKey(key,opt.label)
if opt.mode then self.keybind:SetMode(opt.mode)end end
return self
end
function Control:GetColorPicker()return self.colorPicker end
function Control:SetColor(v)if self.type=="color"then return self:Set(v)elseif self.colorPicker then self.colorPicker:Set(v)end
return self end
function Control:SetWrap(v)self.wrap=v~=false
return self end
function Control:GetWrap()return self.wrap==true end
function Control:SetMaxLines(v)self.maxLines=v and max(1,floor(tonumber(v)or 1))or nil
return self end
function Control:SetLineHeight(v)self.lineHeight=max(10,tonumber(v)or 16)
return self end
function Control:GetPickerWidth(maxW)
    local k=self.type=="keybind"and self or self.keybind
if not k then return nil end
local label=(k.capture and"..."or(k.keyLabel or(k.key and tostring(k.key):upper()or"None")))
local w=max(REF.Full.keyMin,measure(label,REF.Full.keyFont,"Verdana")+REF.Full.keyPad*2)
return min(w,tonumber(maxW)or REF.Full.keyMax)
end
function Control:SetColumn(v)self.column=max(1,floor(tonumber(v)or 1))
return self end
function Control:SetRow(v)self.row=max(1,floor(tonumber(v)or 1))
return self end
function Control:SetSpan(v)self.span=max(1,floor(tonumber(v)or 1))
return self end
function Control:SetOrder(i)if self.section then self.section:MoveControl(self,i)end
return self end
function Control:MoveBefore(c)if self.section and c and c.section==self.section then local i=indexOf(self.section.controls,c)
if i then self.section:MoveControl(self,i)end end
return self end
function Control:MoveAfter(c)if self.section and c and c.section==self.section then local i=indexOf(self.section.controls,c)
if i then self.section:MoveControl(self,i+1)end end
return self end
function Control:Destroy()if self.destroyed then return end
self.destroyed=true
if self.section then removeValue(self.section.controls,self)end
if self.flag and self.window then self.window.flags[self.flag]=nil end end
Control.Remove=Control.Destroy

function Control:SetOptions(list,opt)
    if self.type~="dropdown"and self.type~="multiselect"then return self end
opt=type(opt)=="table"and opt or{}
local oldText=self.type=="dropdown"and self:Get()or self:GetSelected()
local oldIndex=self.value
self.options=arr(list)
    if self.type=="dropdown"then local i=1
if opt.preserve~="index"and oldText~=nil then i=getOptionIndex(self,oldText)or 1 elseif type(oldIndex)=="number"then i=clamp(oldIndex,1,max(1,#self.options))end
self.value=i
    else local new={}
local set={}
if opt.preserve~="index"then for _,x in ipairs(oldText or{})do set[tostring(x)]=true end end
for i,x in ipairs(self.options)do new[i]=(opt.preserve=="index"and oldIndex[i]==true)or set[tostring(x)]==true end
self.value=new end
    if opt.notify then controlCallback(self,false)end
return self
end
function Control:GetOptions()if self.optionsSource then self:RefreshOptionsSource(false)end
return arr(self.options)end
function Control:GetOptionCount()return#(self.options or{})end
function Control:FindOption(v)return getOptionIndex(self,v)end
function Control:HasOption(v)return getOptionIndex(self,v)~=nil end
function Control:AddOption(v,index)local n=#self.options+1
local i=index and clamp(floor(index),1,n)or n
insert(self.options,i,v)
if self.type=="multiselect"then insert(self.value,i,false)elseif self.type=="dropdown"and self.value>=i then self.value=self.value+1 end
return self end
Control.InsertOption=Control.AddOption
function Control:SetOption(i,v,opt)i=floor(tonumber(i)or 0)
if i>=1 and i<=#self.options then self.options[i]=v
if type(opt)=="table"and opt.notify then controlCallback(self,false)end end
return self end
function Control:RemoveOption(which,opt)local i=getOptionIndex(self,which)
if not i then return self end
remove(self.options,i)
if self.type=="multiselect"then local was=remove(self.value,i)
if was and type(opt)=="table"and opt.notify then controlCallback(self,false)end else if self.value>i then self.value=self.value-1 elseif self.value>#self.options then self.value=max(1,#self.options)end end
return self end
function Control:ClearOptions(opt)local had=self.type=="multiselect"and self:GetSelectedCount()>0
self.options={}
if self.type=="multiselect"then self.value={}else self.value=1 end
if had and type(opt)=="table"and opt.notify then controlCallback(self,false)end
return self end
function Control:MoveOption(from,to)from=floor(tonumber(from)or 0)
to=clamp(floor(tonumber(to)or from),1,#self.options)
if from<1 or from>#self.options or from==to then return self end
local v=remove(self.options,from)
insert(self.options,to,v)
if self.type=="multiselect"then local s=remove(self.value,from)
insert(self.value,to,s)elseif self.value==from then self.value=to elseif from<self.value and to>=self.value then self.value=self.value-1 elseif from>self.value and to<=self.value then self.value=self.value+1 end
return self end
function Control:RefreshOptions(list,preserve,opt)opt=type(opt)=="table"and opt or{}
opt.preserve=preserve==nil and"text"or preserve
return self:SetOptions(list,opt)end
function Control:SetOptionsSource(fn,opt)self.optionsSource=type(fn)=="function"and fn or nil
self.optionsSourceOpt=type(opt)=="table"and opt or{}
self.optionsSourceLast=0
return self end
function Control:ClearOptionsSource()self.optionsSource=nil
return self end
function Control:RefreshOptionsSource(force)if not self.optionsSource then return self end
local n=nowMs()
local interval=tonumber(self.optionsSourceOpt.interval)or 250
if not force and n-(self.optionsSourceLast or 0)<interval then return self end
self.optionsSourceLast=n
local ok,q=pcall(self.optionsSource,self)
if ok and type(q)=="table"then self:SetOptions(q,{preserve=self.optionsSourceOpt.preserve or"text",notify=self.optionsSourceOpt.notify==true})end
return self end
function Control:GetSelected()return self.type=="multiselect"and self:Get()or nil end
function Control:GetSelectedIndices()if self.type~="multiselect"then return nil end
local n={}for i=1,#self.options do if self.value[i]then n[#n+1]=i end end return n end
function Control:GetSelectedCount()if self.type~="multiselect"then return 0 end
local n=0 for i=1,#self.options do if self.value[i]then n=n+1 end end return n end
function Control:IsSelected(which)local i=self.type=="multiselect"and getOptionIndex(self,which)
return i and self.value[i]==true or false end
function Control:SetSelected(which,on,silent)local i=self.type=="multiselect"and getOptionIndex(self,which)
if i then local old=self.value[i]
self.value[i]=on~=false
if old~=self.value[i]then controlCallback(self,silent)end end
return self end
function Control:ToggleOption(which,silent)local i=self.type=="multiselect"and getOptionIndex(self,which)
if i then return self:SetSelected(i,not self.value[i],silent)end return self end
function Control:SelectAll(silent)if self.type=="multiselect"then for i=1,#self.options do self.value[i]=true end
controlCallback(self,silent)end
return self end
function Control:ClearSelection(silent)if self.type=="multiselect"then for i=1,#self.options do self.value[i]=false end
controlCallback(self,silent)end
return self end
function Control:GetSummary()if self.type~="multiselect"then return nil end
local q=self:Get()
if#q==0 then return self.noneText or"None"end
if self.summaryMode=="count"or(self.summaryMode=="auto"and#q>(self.summaryItems or 2))then return tostring(#q).." selected"end
local n={}for i=1,min(#q,self.summaryItems or 2)do n[#n+1]=tostring(q[i])end
if#q>#n then n[#n+1]="+"..(#q-#n)end
return concat(n,", ")end

function Control:SetPlaceholder(v)if self.type=="input"then self.placeholder=tostring(v or"")end
return self end
function Control:GetPlaceholder()return self.type=="input"and(self.placeholder or"")or nil end
function Control:SetMaxLength(v)if self.type=="input"then self.maxLength=max(0,floor(tonumber(v)or 0))
self:Set(self.value,true)end
return self end
function Control:GetMaxLength()return self.type=="input"and self.maxLength or nil end
function Control:SetNumeric(v,allowFloat,allowNegative)if self.type=="input"then self.numeric=v==true
if allowFloat~=nil then self.allowFloat=allowFloat~=false end
if allowNegative~=nil then self.allowNegative=allowNegative~=false end
self:Set(self.value,true)end
return self end
function Control:SetPassword(v)if self.type=="input"then self.password=v==true end
return self end
function Control:IsPassword()return self.type=="input"and self.password==true or false end
function Control:OnSubmit(fn)if self.type=="input"then self.submitCallback=fn end
return self end
function Control:Submit()if self.type=="input"and type(self.submitCallback)=="function"then pcall(self.submitCallback,self.value,self)end
return self end
function Control:Clear(silent)if self.type=="input"then return self:Set("",silent)elseif self.type=="multiselect"then return self:ClearSelection(silent)end
return self end
function Control:Append(v,silent)if self.type=="input"then return self:Set(tostring(self.value or"")..tostring(v or""),silent)end
return self end
function Control:GetNumber(default)local n=self.type=="input"and tonumber(self.value)or nil
return n==nil and default or n end
function Control:IsFocused()return self.type=="input"and self.window and self.window.inputEdit and self.window.inputEdit.control==self or false end
function Control:Focus()if self.type=="input"and self.window then self.window:_focusInput(self)end
return self end
function Control:Blur()if self.window and self.window.inputEdit and self.window.inputEdit.control==self then self.window.inputEdit=nil end
return self end
function Control:GetCursor()return self:IsFocused()and self.window.inputEdit.cursor or nil end
function Control:SetCursor(v)if self:IsFocused()then self.window.inputEdit.cursor=clamp(floor(tonumber(v)or 0),0,#tostring(self.value or""))end
return self end
function Control:SetMaxVisibleOptions(n)self.maxVisibleOptions=max(1,floor(tonumber(n)or 1))
return self end
function Control:GetMaxVisibleOptions()return self.maxVisibleOptions or 7 end
function Control:SetDropdownScrollStep(n)self.dropdownScrollStep=max(1,floor(tonumber(n)or 1))
return self end
function Control:GetDropdownScrollStep()return self.dropdownScrollStep or 1 end
function Control:SetDropdownScroll(n)self.dropdownScroll=max(0,floor(tonumber(n)or 0))
return self end
function Control:GetDropdownScroll()return self.dropdownScroll or 0 end
function Control:ScrollOptionsTo(which)local i=getOptionIndex(self,which)
if i then self.dropdownScroll=max(0,i-1)end
return self end

for _,cls in ipairs{Control,Section,Tab}do
    function cls:ShowWhen(source,expected)return setRule(self,source,expected,false)end
    cls.VisibleWhen=cls.ShowWhen
    function cls:HideWhen(source,expected)return setRule(self,source,expected,true)end
    function cls:RefreshVisibility()return self end
    function cls:ClearVisibilityRule()self.visibilityRule=nil
return self end
end

local function finalizeControl(c,opt)
    opt=type(opt)=="table"and opt or{}
c.visible=opt.visible~=false
c.disabled=opt.disabled==true
c.flag=opt.flag and tostring(opt.flag)or nil
c.noConfig=opt.noConfig==true
c.column=tonumber(opt.controlColumn or opt.column)
c.row=tonumber(opt.controlRow or opt.row)
c.span=tonumber(opt.controlSpan or opt.span)
c.wrap=opt.wrap~=nil and opt.wrap~=false or(c.type=="label"or c.type=="value")
c.maxLines=opt.maxLines and max(1,floor(opt.maxLines))or nil
c.lineHeight=tonumber(opt.lineHeight)or(c.type=="label"and 18 or 19)
c.textPadding=tonumber(opt.textPadding)or 0
    c.maxVisibleOptions=opt.maxVisibleOptions or 7
c.dropdownScrollStep=opt.dropdownScrollStep or 1
c.summaryMode=opt.summaryMode or"auto"
c.summaryItems=opt.summaryItems or 2
c.noneText=tostring(opt.noneText or"None")
    if c.flag then c.window.flags[c.flag]=c end
    if type(opt.callback)=="function"then c.callback=opt.callback end
    return c
end
local function addControl(sec,t,label,opt)
    local c=setmetatable({kind="Control",id=newId("control"),type=t,label=tostring(label or""),section=sec,tab=sec.tab,window=sec.window},Control)
sec.controls[#sec.controls+1]=c
return finalizeControl(c,opt)
end

function Section:Toggle(label,default,opt)
    if type(opt)=="function"then opt={callback=opt}else opt=type(opt)=="table"and opt or{}end
local c=addControl(self,"toggle",label,opt)
c.value=default==true
    if type(opt.keybind)=="table"then c:SetKeybind(opt.keybind.key,opt.keybind)end
    if type(opt.colorPicker)=="table"then local q=setmetatable({kind="Control",type="color",label=label,section=self,tab=self.tab,window=self.window,value=rgba(opt.colorPicker.value or opt.colorPicker.color or{255,255,255,255}),visible=true,flag=opt.colorPicker.flag},Control)
if q.flag then self.window.flags[q.flag]=q end
c.colorPicker=q end
    return c
end
Section.AddToggle=Section.Toggle
Section.Checkbox=Section.Toggle
function Section:ToggleKeybind(label,default,key,opt)opt=copy(type(opt)=="table"and opt or{})
opt.keybind=type(opt.keybind)=="table"and opt.keybind or{}
opt.keybind.key=key
return self:Toggle(label,default,opt)end
Section.AddToggleKeybind=Section.ToggleKeybind
function Section:Slider(label,lo,hi,default,opt)opt=type(opt)=="table"and opt or{}
local c=addControl(self,"slider",label,opt)
c.min=tonumber(lo)or 0
c.max=tonumber(hi)or 100
if c.min>c.max then c.min,c.max=c.max,c.min end
c.float=opt.float==true
c.clampValue=opt.clamp==true or opt.clampValue==true
c.format=opt.format
c.value=tonumber(default)or c.min
if c.clampValue then c.value=clamp(c.value,c.min,c.max)end
return c end
Section.AddSlider=Section.Slider
function Section:Dropdown(label,options,default,opt)if type(opt)=="function"then opt={callback=opt}else opt=type(opt)=="table"and opt or{}end
local c=addControl(self,"dropdown",label,opt)
c.options=arr(options)
c.value=1
c:Set(default or 1,true)
return c end
Section.AddDropdown=Section.Dropdown
Section.Combo=Section.Dropdown
function Section:MultiSelect(label,options,default,opt)opt=type(opt)=="table"and opt or{}
local c=addControl(self,"multiselect",label,opt)
c.options=arr(options)
c.value={}
c:Set(default or{},true)
return c end
Section.AddMultiSelect=Section.MultiSelect
Section.MultiDropdown=Section.MultiSelect
Section.AddMultiDropdown=Section.MultiSelect
function Section:Input(label,default,opt)opt=type(opt)=="table"and opt or{}
local c=addControl(self,"input",label,opt)
c.value=""
c.placeholder=tostring(opt.placeholder or"")
c.maxLength=max(0,floor(tonumber(opt.maxLength)or 256))
c.numeric=opt.numeric==true
c.allowFloat=opt.allowFloat~=false
c.allowNegative=opt.allowNegative~=false
c.password=opt.password==true
c.submitCallback=opt.onSubmit
c.blurOnSubmit=opt.blurOnSubmit~=false
c:Set(default or"",true)
return c end
Section.AddInput=Section.Input
Section.Textbox=Section.Input
Section.AddTextbox=Section.Input
Section.TextInput=Section.Input
Section.AddTextInput=Section.Input
function Section:ColorPicker(label,default,opt)if type(opt)=="function"then opt={callback=opt}else opt=type(opt)=="table"and opt or{}end
local c=addControl(self,"color",label,opt)
c.value=rgba(default or{255,255,255,255})
return c end
Section.AddColorPicker=Section.ColorPicker
Section.Color=Section.ColorPicker
function Section:Keybind(label,key,opt)opt=type(opt)=="table"and opt or{}
local c=addControl(self,"keybind",label,opt)
c.key=key
c.keyLabel=opt.label or(key and tostring(key):upper()or"None")
c.mode=opt.mode or"Hold"
c.active=c.mode=="Always"
c.last=false
c.keyboardOnly=opt.keyboardOnly==true
c.keybindList=opt.keybindList~=false
return c end
Section.AddKeybind=Section.Keybind
Section.Hotkey=Section.Keybind
function Section:Button(label,fn,opt)opt=type(opt)=="table"and opt or{}
local c=addControl(self,"button",label,opt)
c.fn=fn
return c end
Section.AddButton=Section.Button
function Section:ButtonPair(leftText,leftFn,rightText,rightFn,opt)opt=type(opt)=="table"and opt or{}
local c=addControl(self,"buttonpair","",opt)
c.leftText=tostring(leftText or"")
c.leftFn=leftFn
c.rightText=tostring(rightText or"")
c.rightFn=rightFn
return c end
Section.AddButtonPair=Section.ButtonPair
function Section:Label(textValue,opt)local c=addControl(self,"label",textValue,type(opt)=="table"and opt or{})
c.value=c.label
return c end
Section.AddLabel=Section.Label
function Section:Separator(textValue,opt)return addControl(self,"separator",textValue,type(opt)=="table"and opt or{})end
Section.AddSeparator=Section.Separator
function Section:Spacer(height,opt)local o=type(opt)=="table"and opt or{}
local c=addControl(self,"spacer","",o)
c.height=max(0,tonumber(height)or 18)
return c end
Section.AddSpacer=Section.Spacer
function Section:Value(label,value,opt)local c=addControl(self,"value",label,type(opt)=="table"and opt or{})
c.valueSource=value
c.valueAccent=opt and opt.accent==true
c.valueMuted=opt and opt.muted==true
return c end
Section.AddValue=Section.Value
Section.InfoRow=Section.Value
Section.AddInfoRow=Section.Value

function Section:SetColumn(n)self.column=max(1,floor(tonumber(n)or 1))
return self end
function Section:SetRow(n)self.row=max(1,floor(tonumber(n)or 1))
return self end
function Section:SetSpan(n)self.span=max(1,floor(tonumber(n)or 1))
return self end
function Section:SetFullWidth(v)self.span=v~=false and(self.window.columns or 2)or 1
return self end
function Section:SetHeight(h)
    if h==nil then self.height=nil
self.sizeMode="auto"
return self end
    if type(h)=="string"then local m=lower(h)
if m=="auto"or m=="content"then self.height=nil
self.sizeMode="auto"elseif m=="fill"or m=="stretch"or m=="flex"then self.height=nil
self.sizeMode="fill"end
return self end
    self.height=tonumber(h)
if self.height then self.sizeMode="fixed"end
return self
end
function Section:GetHeight()return self.height end
function Section:SetSizeMode(mode,height)mode=lower(tostring(mode or"auto"))
if mode=="content"then mode="auto"elseif mode=="stretch"or mode=="flex"then mode="fill"end
if mode~="auto"and mode~="fixed"and mode~="fill"then return self end
self.sizeMode=mode
if mode=="fixed"and tonumber(height)then self.height=tonumber(height)elseif mode~="fixed"then self.height=nil end
return self end
function Section:GetSizeMode()return self.sizeMode or"auto"end
function Section:SetAutoSize(v)if v~=false then self.sizeMode="auto"
self.height=nil elseif self.sizeMode=="auto"then self.sizeMode="fixed"end
return self end
function Section:SetFillHeight(v)if v~=false then self.sizeMode="fill"
self.height=nil elseif self.sizeMode=="fill"then self.sizeMode="auto"end
return self end
function Section:SetMinHeight(v)self.minHeight=tonumber(v)
return self end
function Section:GetMinHeight()return self.minHeight end
function Section:SetMaxHeight(v)self.maxHeight=tonumber(v)
return self end
function Section:GetMaxHeight()return self.maxHeight end
function Section:GetResolvedHeight()return self.resolvedHeight or 0 end
function Section:SetColumns(n)self.columns=clamp(floor(tonumber(n)or 1),1,4)
return self end
function Section:GetColumns()return self.columns or 1 end
function Section:SetControlGap(n)self.controlGap=max(0,tonumber(n)or 0)
return self end
function Section:SetVisible(v)self.visible=v~=false
return self end
function Section:SetScrollStep(n)self.scrollStep=max(1,tonumber(n)or REF.Full.rowH)
return self end
function Section:GetScrollStep()return self.scrollStep or REF.Full.rowH end
function Section:ScrollTo(n)self.scrollTarget=clamp(tonumber(n)or 0,0,self.maxScroll or 0)
return self end
function Section:ScrollBy(n)return self:ScrollTo((self.scrollTarget or self.scroll or 0)+(tonumber(n)or 0))end
function Section:ScrollTop()return self:ScrollTo(0)end
function Section:ScrollBottom()return self:ScrollTo(self.maxScroll or 0)end
function Section:GetControls()local n={}for _,c in ipairs(self.controls)do if not c.destroyed then n[#n+1]=c end end return n end
function Section:GetControl(which)if type(which)=="number"then return self.controls[which]end
for _,c in ipairs(self.controls)do if c==which or c.flag==which or c.label==which then return c end end end
function Section:GetControlCount()return#self:GetControls()end
function Section:RemoveControl(which)local c=self:GetControl(which)
if c then c:Destroy()end
return self end
function Section:ClearControls()for i=#self.controls,1,-1 do self.controls[i]:Destroy()end
return self end
function Section:MoveControl(which,newIndex)local c=self:GetControl(which)
if not c then return self end
local i=indexOf(self.controls,c)
if not i then return self end
remove(self.controls,i)
insert(self.controls,clamp(floor(tonumber(newIndex)or 1),1,#self.controls+1),c)
return self end
function Section:MoveControlBefore(which,target)local t=self:GetControl(target)
if t then local i=indexOf(self.controls,t)
return self:MoveControl(which,i)end return self end
function Section:MoveControlAfter(which,target)local t=self:GetControl(target)
if t then local i=indexOf(self.controls,t)
return self:MoveControl(which,i+1)end return self end
function Section:SetOrder(index)if self.tab then self.tab:MoveSection(self,index)end
return self end
function Section:Destroy()if self.destroyed then return end
self.destroyed=true
for _,c in ipairs(self.controls)do c:Destroy()end
if self.tab then removeValue(self.tab.sections,self)end end
Section.Remove=Section.Destroy

function Tab:Section(name,opt)
    opt=type(opt)=="table"and opt or{}
    local count=#self.sections
local wc=max(1,self.window and self.window.columns or 2)
local autoCol=(count%wc)+1
local autoRow=floor(count/wc)+1
    local s=setmetatable({kind="Section",id=newId("section"),name=tostring(name or"SECTION"),tab=self,window=self.window,controls={},column=max(1,floor(tonumber(opt.column)or autoCol)),row=max(1,floor(tonumber(opt.row)or autoRow)),span=max(1,floor(tonumber(opt.span)or 1)),columns=clamp(floor(tonumber(opt.columns)or 1),1,4),controlGap=max(0,tonumber(opt.controlGap)or 12),sizeMode="auto",height=nil,minHeight=tonumber(opt.minHeight),maxHeight=tonumber(opt.maxHeight),visible=opt.visible~=false,scroll=0,scrollTarget=0,maxScroll=0,scrollStep=tonumber(opt.scrollStep)or REF.Full.rowH},Section)
    if opt.fillHeight==true then s.sizeMode="fill"elseif opt.autoSize==true or opt.autosize==true then s.sizeMode="auto"elseif type(opt.height)=="number"then s.sizeMode="fixed"
s.height=opt.height elseif type(opt.height)=="string"then s:SetHeight(opt.height)elseif opt.sizeMode or opt.heightMode then s:SetSizeMode(opt.sizeMode or opt.heightMode,opt.height)end
    self.sections[#self.sections+1]=s
return s
end
Tab.AddSection=Tab.Section
Tab.CreateSection=Tab.Section
function Tab:_implicitSection(opt)
    opt=type(opt)=="table"and opt or{}
if kind(opt.section)=="Section"then return opt.section end
if type(opt.section)=="string"then for _,s in ipairs(self.sections)do if s.name==opt.section then return s end end end
    if self._implicit and not self._implicit.destroyed then return self._implicit end
self._implicit=self:Section("GENERAL",{column=1,row=1,span=self.window.columns or 2})
return self._implicit
end
for _,name in ipairs{"Toggle","ToggleKeybind","Slider","Dropdown","MultiSelect","Input","ColorPicker","Keybind","Button","ButtonPair","Label","Separator","Spacer","Value"}do Tab["Add"..name]=function(self,...)local args={...}
local opt=args[#args]
return self:_implicitSection(type(opt)=="table"and opt or nil)[name](self:_implicitSection(type(opt)=="table"and opt or nil),...)end end
Tab.Checkbox=Tab.AddToggle
Tab.Combo=Tab.AddDropdown
Tab.MultiDropdown=Tab.AddMultiSelect
Tab.AddMultiDropdown=Tab.AddMultiSelect
Tab.Textbox=Tab.AddInput
Tab.AddTextbox=Tab.AddInput
Tab.TextInput=Tab.AddInput
Tab.AddTextInput=Tab.AddInput
Tab.Color=Tab.AddColorPicker
Tab.Hotkey=Tab.AddKeybind
Tab.InfoRow=Tab.AddValue
Tab.AddInfoRow=Tab.AddValue
function Tab:SetVisible(v)self.visible=v~=false
return self end
function Tab:Select()if self.window then self.window:SelectTab(self)end
return self end
function Tab:OnSelected(fn)self.onSelected=fn
return self end
function Tab:SetScrollStep(n)self.scrollStep=max(1,tonumber(n)or REF.Full.rowH)
return self end
function Tab:GetScrollStep()return self.scrollStep or REF.Full.rowH end
function Tab:ScrollTo(n)self.pageTarget=clamp(tonumber(n)or 0,0,self.maxScroll or 0)
return self end
function Tab:ScrollBy(n)return self:ScrollTo((self.pageTarget or self.pageScroll or 0)+(tonumber(n)or 0))end
function Tab:ScrollTop()return self:ScrollTo(0)end
function Tab:ScrollBottom()return self:ScrollTo(self.maxScroll or 0)end
function Tab:GetScroll()return self.pageScroll or 0 end
function Tab:GetMaxScroll()return self.maxScroll or 0 end
function Tab:SetMainScrollEnabled(v)self.mainScrollEnabled=v~=false
return self end
function Tab:GetMainScrollEnabled()return self.mainScrollEnabled~=false end
function Tab:GetSections()local n={}for _,s in ipairs(self.sections)do if not s.destroyed then n[#n+1]=s end end return n end
function Tab:GetSection(which)if type(which)=="number"then return self.sections[which]end
for _,s in ipairs(self.sections)do if s==which or s.name==which then return s end end end
function Tab:GetSectionCount()return#self:GetSections()end
function Tab:RemoveSection(which)local s=self:GetSection(which)
if s then s:Destroy()end
return self end
function Tab:ClearSections()for i=#self.sections,1,-1 do self.sections[i]:Destroy()end
return self end
function Tab:MoveSection(which,index)local s=self:GetSection(which)
if not s then return self end
local i=indexOf(self.sections,s)
remove(self.sections,i)
insert(self.sections,clamp(floor(tonumber(index)or 1),1,#self.sections+1),s)
return self end
function Tab:InsertSection(index,name,opt)local s=self:Section(name,opt)
return self:MoveSection(s,index)and s or s end
function Tab:SetOrder(index)if self.window then self.window:MoveTab(self,index)end
return self end
function Tab:Destroy()if self.destroyed then return end
self.destroyed=true
for _,s in ipairs(self.sections)do s:Destroy()end
if self.window then removeValue(self.window.tabs,self)
if self.window.activeTab==self then self.window.activeTab=self.window.tabs[1]end end end


local function loadTexture(path)
    if type(path)=="number"then return path end
    if type(path)~="string"or path==""then return nil end
    if type(file)~="table"or type(file.read)~="function"or type(utility.LoadImage)~="function"then return nil end
    local ok,data=pcall(file.read,path)
if not ok or type(data)~="string"or data==""then return nil end
    local ok2,id=pcall(utility.LoadImage,data)
if ok2 and type(id)=="number"then return id end
return nil
end
local IMAGE_WHITE=Color3.new(1,1,1)
local function drawImage(id,x,y,w,h,a)
    if type(id)~="number"then return false end
    local fn=draw and(draw.Image or draw.image)
    if type(fn)~="function"then return false end
    if type(x)~="number"or type(y)~="number"or type(w)~="number"or type(h)~="number"or w<=0 or h<=0 then return false end
    x,y,w,h=floor(x+.5),floor(y+.5),max(1,floor(w+.5)),max(1,floor(h+.5))

    -- Prefer the raw Serotonin image overload: no theme tint, no glass tint,
    -- no alpha/color multiplication. Fall back to explicit neutral white only
    -- if this runtime rejects the short overload.
    local ok,err=pcall(fn,id,x,y,w,h)
    if not ok then ok,err=pcall(fn,id,x,y,w,h,IMAGE_WHITE,1)end
    if not ok then E.drawErrors=E.drawErrors+1;E.lastDrawError=tostring(err)end
    return ok
end

function Fawn:CreateWindow(opt)
    opt=type(opt)=="table"and opt or{}
local themeName=opt.theme or"Modern Blue"
if themeName=="Neverlose"or themeName=="Fawn"then themeName="Modern Blue"end
    local w=setmetatable({
        kind="Window",id=newId("window"),brand=tostring(opt.title or"FAWN"),subtitle=tostring(opt.subtitle or"SEROTONIN"),logo=tostring(opt.logo or"F"),
        x=tonumber(opt.x)or 30,y=tonumber(opt.y)or 35,width=tonumber(opt.width)or REF.Width,height=tonumber(opt.height)or REF.Height,
        minWidth=tonumber(opt.minWidth)or 900,minHeight=tonumber(opt.minHeight)or 620,maxWidth=tonumber(opt.maxWidth)or 1900,maxHeight=tonumber(opt.maxHeight)or 1300,
        scale=clamp(tonumber(opt.scale)or 1,.55,1.65),visible=opt.visible~=false,destroyed=false,columns=clamp(floor(tonumber(opt.columns)or 2),1,4),tabs={},flags={},activeTab=nil,
        themeName=themeName,theme=copy(PRESETS[themeName]or PRESETS["Modern Blue"]),independentTheme=opt.independentTheme==true,font="Verdana",corner=tonumber(opt.corner)or 22,borderThickness=max(1,tonumber(opt.borderThick or opt.borderThickness)or 1),
        toggleKey=opt.toggleKey or"Insert",toggleLabel=opt.toggleLabel or"INSERT",toggleControl=nil,followMenu=opt.followMenu==true,mainScrollEnabled=opt.mainScrollEnabled~=false,smoothScroll=opt.smoothScroll~=false,scrollSpeed=tonumber(opt.scrollSpeed)or 12,
        liquidGlass=opt.liquidGlass==true,glassOpacity=clamp(tonumber(opt.glassOpacity)or .72,.18,1),animations=opt.animations~=false,animationSpeed=tonumber(opt.animationSpeed)or 10,accentGlow=opt.accentGlow==true,compact=opt.compact==true,layoutMode=opt.layoutMode or"Modern",
        tabBarVisible=opt.tabBar~=false,backgroundBlur=opt.backgroundBlur==true,backgroundSnow=opt.backgroundSnow==true,
        draggable=opt.draggable~=false,resizable=opt.resizable~=false,dragging=nil,resizing=nil,sidebarScroll=0,sidebarTarget=0,inputEdit=nil,captureBind=nil,activeSlider=nil,openDrop=nil,keyMenu=nil,colorPopup=nil,configPopup=nil,groupPopup=nil,accountOpen=false,accountAnim=0,searchOpen=false,search="",searchEdit=nil,
        profileName=tostring(opt.user or opt.profileName or"User"),profileSubtitle=tostring(opt.userSub or opt.profileSubtitle or""),profileImage=nil,profileImagePath=nil,profileClick=nil,
        logoImage=nil,logoImagePath=nil,groups=arr(opt.groups or opt.weaponGroups or{"Global","Pistols","Heavy Pistols","SMGs","Rifles","Snipers","Auto Snipers","Shotguns","Machine Guns"}),group=tostring(opt.group or"Global"),groupClick=nil,
        configName=tostring(opt.config or"Default"),configProfiles={},notificationPosition=opt.notificationPosition or E.notificationPosition,
        outlineColor=rgba(opt.outlineColor or(PRESETS[themeName]or MODERN).outline,{55,58,68,255}),outlineStrength=clamp(tonumber(opt.outlineStrength)or 1,.25,3),
        settingsPage=nil,onTabChanged=nil,profileMenuItems={},
        _pixel={},_layout=nil,_lastMouseX=0,_lastMouseY=0
    },Window)
    w.width=clamp(w.width,w.minWidth,w.maxWidth)
w.height=clamp(w.height,w.minHeight,w.maxHeight)
w.configProfiles[w.configName]={}
    if opt.profileImage then w:SetProfileImage(opt.profileImage)end
if opt.logoImage then w:SetLogoImage(opt.logoImage)end
    E.windows[#E.windows+1]=w
return w
end
function Fawn:CreatePanel(opt)opt=copy(type(opt)=="table"and opt or{})
opt.tabBar=false
opt.width=opt.width or 560
opt.height=opt.height or 440
opt.minWidth=opt.minWidth or 360
opt.minHeight=opt.minHeight or 260
local w=self:CreateWindow(opt)
w.kind="Panel"
w.brand=tostring(opt.title or"PANEL")
w.subtitle=tostring(opt.subtitle or"")
w.columns=clamp(floor(tonumber(opt.columns)or 1),1,2)
return w end
function Fawn.Window(a,b)return Fawn:CreateWindow(a==Fawn and b or a)end
function Fawn.Panel(a,b)return Fawn:CreatePanel(a==Fawn and b or a)end
Fawn.NewWindow=Fawn.Window
Fawn.NewPanel=Fawn.Panel
Fawn.new=Fawn.Window

function Window:SetVisible(v)self.visible=v~=false
if not self.visible then self:_closePopups()end
return self end
function Window:Toggle()return self:SetVisible(not self.visible)end
function Window:SetToggleKey(key,label)self.toggleKey=key
self.toggleLabel=label or(key and tostring(key):upper()or"None")
return self end
function Window:BindToggleKey(control)self.toggleControl=control
return self end
function Window:SetPosition(x,y)self.x=tonumber(x)or self.x
self.y=tonumber(y)or self.y
return self end
function Window:GetPosition()return self.x,self.y end
function Window:SetSize(w,h)self.width=clamp(tonumber(w)or self.width,self.minWidth,self.maxWidth)
self.height=clamp(tonumber(h)or self.height,self.minHeight,self.maxHeight)
return self end
function Window:GetSize()return self.width,self.height end
function Window:SetScale(v)self.scale=clamp(tonumber(v)or self.scale,.55,1.65)
self:_closePopups()
return self end
function Window:GetScale()return self.scale end
function Window:Center()local sw,sh=screenSize()
self.x=(sw-self.width*self.scale)/2
self.y=(sh-self.height*self.scale)/2
return self end
function Window:SetColumns(n)self.columns=clamp(floor(tonumber(n)or 2),1,4)
return self end
function Window:GetColumns()return self.columns end
function Window:SetTabBarVisible(v)self.tabBarVisible=v~=false
return self end
function Window:IsTabBarVisible()return self.tabBarVisible~=false end
function Window:SetMainScrollEnabled(v)self.mainScrollEnabled=v~=false
return self end
function Window:GetMainScrollEnabled()return self.mainScrollEnabled~=false end
function Window:SetScrollSpeed(v)self.scrollSpeed=max(1,tonumber(v)or 12)
return self end
function Window:GetScrollSpeed()return self.scrollSpeed end
function Window:SetSmoothScroll(v)self.smoothScroll=v~=false
return self end
function Window:SetAnimations(v)self.animations=v~=false
return self end
function Window:SetAnimationSpeed(v)self.animationSpeed=max(.1,tonumber(v)or 10)
return self end
function Window:SetAccentGlow(v)self.accentGlow=v==true
return self end
function Window:SetCompact(v)self.compact=v==true
return self end
function Window:SetLayoutMode(v)self.layoutMode=tostring(v or"Modern")
return self end
function Window:SetBackgroundBlur(v)self.backgroundBlur=v==true
return self end
function Window:SetBackgroundSnow(v)self.backgroundSnow=v==true
return self end
function Window:SetFont(_)self.font="Verdana"
return self end
function Window:SetCornerRadius(v)self.corner=max(0,tonumber(v)or self.corner)
return self end
function Window:SetBorderThickness(v)self.borderThickness=max(.5,tonumber(v)or self.borderThickness)
return self end
function Window:SetLiquidGlass(v)self.liquidGlass=v==true
return self end
function Window:GetLiquidGlass()return self.liquidGlass==true end
function Window:SetGlassOpacity(v)local n=tonumber(v)or self.glassOpacity
if n>1 then n=n/100 end
self.glassOpacity=clamp(n,.18,1)
return self end
function Window:GetGlassOpacity()return self.glassOpacity end
function Window:SetOutlineColor(v)self.outlineColor=rgba(v,self.outlineColor)
return self end
function Window:GetOutlineColor()return copy(self.outlineColor)end
function Window:SetOutlineStrength(v)self.outlineStrength=clamp(tonumber(v)or self.outlineStrength,.25,3)
return self end
function Window:GetOutlineStrength()return self.outlineStrength end
function Window:GetStyle()return{scale=self.scale,corner=self.corner,borderThickness=self.borderThickness,liquidGlass=self.liquidGlass,glassOpacity=self.glassOpacity,outlineColor=copy(self.outlineColor),outlineStrength=self.outlineStrength,layoutMode=self.layoutMode,smoothScroll=self.smoothScroll,animations=self.animations}end
function Window:SetStyle(t)if type(t)~="table"then return self end
if t.scale then self:SetScale(t.scale)end
if t.corner then self:SetCornerRadius(t.corner)end
if t.borderThickness then self:SetBorderThickness(t.borderThickness)end
if t.liquidGlass~=nil then self:SetLiquidGlass(t.liquidGlass)end
if t.glassOpacity then self:SetGlassOpacity(t.glassOpacity)end
if t.outlineColor then self:SetOutlineColor(t.outlineColor)end
if t.outlineStrength then self:SetOutlineStrength(t.outlineStrength)end
if t.smoothScroll~=nil then self:SetSmoothScroll(t.smoothScroll)end
if t.animations~=nil then self:SetAnimations(t.animations)end
return self end
function Window:SetTheme(name,localOnly)
    name=tostring(name or"")
if name=="Neverlose"or name=="Fawn"then name="Modern Blue"end
local p=PRESETS[name]
if not p then return self end
self.themeName=name
self.theme=copy(p)
if localOnly==false and not self.independentTheme then Fawn:SetTheme(name)end
return self
end
function Window:SetThemeColor(key,v,localOnly)if self.theme[key]then self.theme[key]=rgba(v,self.theme[key])
self.themeName="Custom"
if key=="outline"then self.outlineColor=rgba(v,self.outlineColor)end
if localOnly==false and not self.independentTheme then local p=PRESETS.Custom or copy(self.theme)
p[key]=rgba(v,p[key])
PRESETS.Custom=p end end
return self end
function Window:GetTheme()return copy(self.theme)end
function Window:SetIndependentTheme(v)self.independentTheme=v~=false
return self end
function Window:GetIndependentTheme()return self.independentTheme==true end
function Window:GetThemeName()return self.themeName end
function Window:GetPixelMetrics()
    local s=self.scale
return{width=self.width*s,height=self.height*s,row=REF.Full.rowH*s,field=REF.Full.ddH*s,controlWidth=REF.Full.ctrlW*s,sidebar=REF.Sidebar*s,contentX=REF.ContentX*s,scale=s}
end
function Window:GetBodyBounds()local s=self.scale
if self.kind=="Panel"or self.tabBarVisible==false then return self.x+18*s,self.y+72*s,(self.width-36)*s,(self.height-90)*s end
return self.x+REF.ContentX*s,self.y+REF.ContentTop*s,(self.width-REF.ContentX-REF.RightMargin)*s,(self.height-REF.ContentTop-15)*s end
function Window:GetLayoutSnapshot()return copy(self._layout or{})end
function Window:GetKeybindPickerWidth(control,maxW)return control and control.GetPickerWidth and control:GetPickerWidth(maxW)or nil end

function Window:SetProfileName(v)self.profileName=tostring(v or"")
return self end
function Window:SetProfileSubtitle(v)self.profileSubtitle=tostring(v or"")
return self end
function Window:SetProfileImage(v)self.profileImagePath=type(v)=="string"and v or nil
self.profileImage=loadTexture(v)
return self end
function Window:ClearProfileImage()self.profileImage=nil
self.profileImagePath=nil
return self end
function Window:SetProfileClick(fn)self.profileClick=type(fn)=="function"and fn or nil
return self end
function Window:SetLogoImage(v)self.logoImagePath=type(v)=="string"and v or nil
self.logoImage=loadTexture(v)
return self end
function Window:ClearLogoImage()self.logoImage=nil
self.logoImagePath=nil
return self end
function Window:SetBranding(opt)opt=type(opt)=="table"and opt or{}
if opt.title~=nil then self.brand=tostring(opt.title)end
if opt.subtitle~=nil then self.subtitle=tostring(opt.subtitle)end
if opt.logo~=nil then self.logo=tostring(opt.logo)end
if opt.image~=nil then self:SetLogoImage(opt.image)end
return self end
function Window:SetGroups(list,current)self.groups=arr(list)
if current then self.group=tostring(current)elseif not indexOf(self.groups,self.group)then self.group=self.groups[1]or"Global"end
return self end
function Window:SetGroup(v)if indexOf(self.groups,v)then self.group=v end
return self end
function Window:GetGroup()return self.group end
function Window:SetGroupClick(fn)self.groupClick=type(fn)=="function"and fn or nil
return self end

function Window:Tab(name,opt)
    opt=type(opt)=="table"and opt or{}
local t=setmetatable({kind="Tab",id=newId("tab"),name=tostring(name or"Tab"),group=tostring(opt.group or"MAIN"),icon=opt.icon or"circle",window=self,sections={},visible=opt.visible~=false,selected=opt.selected==true,mainScrollEnabled=opt.mainScrollEnabled~=false,pageScroll=0,pageTarget=0,maxScroll=0,scrollStep=tonumber(opt.scrollStep)or REF.Full.rowH},Tab)
self.tabs[#self.tabs+1]=t
if not self.activeTab or opt.selected==true then self.activeTab=t end
return t
end
Window.AddTab=Window.Tab
Window.CreateTab=Window.Tab
function Window:SelectTab(which)
    local old=self.activeTab
local target=nil
if kind(which)=="Tab"then target=which elseif type(which)=="number"then target=self.tabs[which]else for _,t in ipairs(self.tabs)do if t.name==which or t.id==which then target=t break end end end
    if target and not target.destroyed and visibilityPass(target)then self.activeTab=target
self:_closePopups()
if old~=target then if type(target.onSelected)=="function"then pcall(target.onSelected,target,self)end
if type(self.onTabChanged)=="function"then pcall(self.onTabChanged,target,indexOf(self.tabs,target),old and indexOf(self.tabs,old)or nil,self)end end end
return self
end
function Window:OnTabChanged(fn)self.onTabChanged=type(fn)=="function"and fn or nil
return self end
function Window:GetTabs()local n={}for _,t in ipairs(self.tabs)do if not t.destroyed then n[#n+1]=t end end return n end
function Window:GetTab(which)if type(which)=="number"then return self.tabs[which]end
for _,t in ipairs(self.tabs)do if t==which or t.name==which or t.id==which then return t end end end
function Window:GetTabCount()return#self:GetTabs()end
function Window:RemoveTab(which)local t=self:GetTab(which)
if t then t:Destroy()end
return self end
function Window:ClearTabs()for i=#self.tabs,1,-1 do self.tabs[i]:Destroy()end
return self end
function Window:MoveTab(which,index)local t=self:GetTab(which)
if not t then return self end
local i=indexOf(self.tabs,t)
remove(self.tabs,i)
insert(self.tabs,clamp(floor(tonumber(index)or 1),1,#self.tabs+1),t)
return self end
function Window:InsertTab(index,name,opt)local t=self:Tab(name,opt)
self:MoveTab(t,index)
return t end
function Window:_activeTab()
    if self.activeTab and not self.activeTab.destroyed then return self.activeTab end
    if #self.tabs==0 then self:Tab(self.kind=="Panel"and"Panel"or"Main",{group="MAIN"})end
self.activeTab=self.tabs[1]
return self.activeTab
end
function Window:AddSection(name,opt)return self:_activeTab():AddSection(name,opt)end
function Window:_implicitSection(opt)return self:_activeTab():_implicitSection(opt)end
for _,name in ipairs{"Toggle","ToggleKeybind","Slider","Dropdown","MultiSelect","Input","ColorPicker","Keybind","Button","ButtonPair","Label","Separator","Spacer","Value"}do Window["Add"..name]=function(self,...)local args={...}
local opt=args[#args]
local s=self:_implicitSection(type(opt)=="table"and opt or nil)
return s[name](s,...)end end
Window.Checkbox=Window.AddToggle
Window.Combo=Window.AddDropdown
Window.MultiDropdown=Window.AddMultiSelect
Window.AddMultiDropdown=Window.AddMultiSelect
Window.Textbox=Window.AddInput
Window.AddTextbox=Window.AddInput
Window.TextInput=Window.AddInput
Window.AddTextInput=Window.AddInput
Window.Color=Window.AddColorPicker
Window.Hotkey=Window.AddKeybind
Window.InfoRow=Window.AddValue
Window.AddInfoRow=Window.AddValue

function Window:GetControl(flag)return self.flags[tostring(flag or"")]end
function Window:GetValue(flag)local c=self:GetControl(flag)
return c and c:Get()or nil end
function Window:SetValue(flag,v,silent)local c=self:GetControl(flag)
if c then c:Set(v,silent)end
return self end
function Window:ForEachControl(fn)for _,t in ipairs(self.tabs)do if not t.destroyed then for _,s in ipairs(t.sections)do if not s.destroyed then for _,c in ipairs(s.controls)do if not c.destroyed then fn(c,s,t)end end end end end end
return self end
function Window:GetConfig()
    local out={version=Fawn.Version,theme=self.themeName,style={scale=self.scale,liquidGlass=self.liquidGlass,glassOpacity=self.glassOpacity},controls={}}
    self:ForEachControl(function(c)if c.flag and not c.noConfig then if c.type=="keybind"then out.controls[c.flag]={type="keybind",key=c.key,label=c.keyLabel,mode=c.mode}elseif c.type=="color"then out.controls[c.flag]={type="color",value=copy(c.value)}elseif c.type~="button"and c.type~="buttonpair"and c.type~="label"and c.type~="separator"and c.type~="spacer"and c.type~="value"then local d={type=c.type,value=copy(c:GetRaw())}
if c.keybind then d.keybind={key=c.keybind.key,label=c.keybind.keyLabel,mode=c.keybind.mode}end
if c.colorPicker then d.color=copy(c.colorPicker.value)end
out.controls[c.flag]=d end end end)
return out
end
function Window:LoadConfig(cfg,silent)
    if type(cfg)~="table"then return self end
if cfg.theme and PRESETS[cfg.theme]then self:SetTheme(cfg.theme)end
if type(cfg.style)=="table"then if cfg.style.scale then self:SetScale(cfg.style.scale)end
if cfg.style.liquidGlass~=nil then self:SetLiquidGlass(cfg.style.liquidGlass)end
if cfg.style.glassOpacity then self:SetGlassOpacity(cfg.style.glassOpacity)end end
    for flag,d in pairs(cfg.controls or{})do local c=self:GetControl(flag)
if c and type(d)=="table"then if c.type=="keybind"then c:SetKey(d.key,d.label)
if d.mode then c:SetMode(d.mode)end else c:Set(d.value,silent)
if c.keybind and d.keybind then c.keybind:SetKey(d.keybind.key,d.keybind.label)
if d.keybind.mode then c.keybind:SetMode(d.keybind.mode)end end
if c.colorPicker and d.color then c.colorPicker:Set(d.color,silent)end end end end
return self
end
function Window:SaveNamedConfig(name)local n=tostring(name or self.configName)
self.configProfiles[n]=self:GetConfig()
self.configName=n
return self end
function Window:LoadNamedConfig(name,silent)local c=self.configProfiles[tostring(name or self.configName)]
if c then self.configName=tostring(name or self.configName)
self:LoadConfig(c,silent)end
return self end
function Window:GetNamedConfigs()local n={}for k in pairs(self.configProfiles)do n[#n+1]=k end
sort(n)
return n end
function Window:DuplicateNamedConfig()local base=self.configName
local name=base.." copy"
local i=2
while self.configProfiles[name]do name=base.." copy "..i
i=i+1 end
self.configProfiles[name]=copy(self.configProfiles[base]or self:GetConfig())
self.configName=name
return name end
function Window:DeleteNamedConfig(name)local n=tostring(name or self.configName)
local names=self:GetNamedConfigs()
if#names<=1 then return false end
self.configProfiles[n]=nil
local nextName=self:GetNamedConfigs()[1]
self.configName=nextName or"Default"
return true end
function Window:Destroy()if self.destroyed then return end
self.destroyed=true
for _,t in ipairs(self.tabs)do t:Destroy()end
for _,o in ipairs(E.overlays)do if o.window==self then o:Destroy()end end
removeValue(E.windows,self)end


local ICON={}
ICON.crosshair=function(x,y,sz,c)local t=max(1,sz*.09)
safeDraw("Circle",x,y,sz*.33,rgb(c),t,24,c[4]or 255)
line(x,y-sz*.5,x,y-sz*.33,c,t)
line(x,y+sz*.33,x,y+sz*.5,c,t)
line(x-sz*.5,y,x-sz*.33,y,c,t)
line(x+sz*.33,y,x+sz*.5,y,c,t)end
ICON.mouse=function(x,y,sz,c)local w,h=sz*.54,sz*.84
rect(x-w*.5,y-h*.5,w,h,c,w*.5)
rect(x-sz*.04,y-h*.5+sz*.16,sz*.08,sz*.16,MODERN.activeItem,sz*.04)end
ICON.image=function(x,y,sz,c)local t=max(1,sz*.09)
local w=sz*.76
outline(x-w*.5,y-w*.5,w,w,c,sz*.12,255,t)
circle(x-w*.5+sz*.23,y-w*.5+sz*.23,sz*.07,c)
line(x-w*.5+sz*.08,y+w*.5-sz*.04,x+sz*.1,y-sz*.06,c,t)
line(x+sz*.1,y-sz*.06,x+w*.5-sz*.04,y+sz*.18,c,t)end
ICON.layers=function(x,y,sz,c)local t=max(1,sz*.09)
local w,hh=sz*.42,sz*.2
line(x-w,y-sz*.2,x,y-sz*.2-hh,c,t)
line(x,y-sz*.2-hh,x+w,y-sz*.2,c,t)
line(x+w,y-sz*.2,x,y-sz*.2+hh,c,t)
line(x,y-sz*.2+hh,x-w,y-sz*.2,c,t)
line(x-w,y,x,y+hh,c,t)
line(x,y+hh,x+w,y,c,t)
line(x-w,y+sz*.2,x,y+sz*.2+hh,c,t)
line(x,y+sz*.2+hh,x+w,y+sz*.2,c,t)end
ICON.misc=function(x,y,sz,c)local t=max(1,sz*.09)
local w,h=sz*.76,sz*.66
outline(x-w*.5,y-h*.5,w,h,c,sz*.12,255,t)
line(x-sz*.2,y-sz*.15,x+sz*.2,y-sz*.15,c,t)
line(x-sz*.2,y,x+sz*.2,y,c,t)
line(x-sz*.2,y+sz*.15,x+sz*.02,y+sz*.15,c,t)end
ICON.save=function(x,y,sz,c)local w=sz*.84
rect(x-w*.5,y-w*.5,w,w,c,sz*.08)
rect(x-sz*.22,y-w*.5+sz*.05,sz*.4,sz*.2,MODERN.card,0)
rect(x-sz*.26,y+sz*.06,sz*.52,sz*.26,MODERN.card,sz*.03)end
ICON.note=function(x,y,sz,c)local t=max(1.5,sz*.12)
circle(x-sz*.16,y+sz*.24,sz*.17,c)
line(x,y+sz*.24,x,y-sz*.42,c,t)
line(x,y-sz*.42,x+sz*.1,y-sz*.26,c,t)
line(x+sz*.1,y-sz*.26,x+sz*.3,y-sz*.16,c,t)end
ICON.search=function(x,y,sz,c)local t=max(1.5,sz*.1)
safeDraw("Circle",x-sz*.08,y-sz*.08,sz*.3,rgb(c),t,24,c[4]or 255)
line(x+sz*.14,y+sz*.14,x+sz*.38,y+sz*.38,c,t)end
ICON.dots=function(x,y,sz,c)local r=sz*.14
circle(x-sz*.36,y,r,c)
circle(x,y,r,c)
circle(x+sz*.36,y,r,c)end
ICON.check=function(x,y,sz,c)local t=max(1.5,sz*.16)
line(x-sz*.32,y,x-sz*.08,y+sz*.26,c,t)
line(x-sz*.08,y+sz*.26,x+sz*.36,y-sz*.3,c,t)end
ICON.settings=function(x,y,sz,c)local t=max(1.5,sz*.11)
safeDraw("Circle",x,y,sz*.28,rgb(c),t,24,c[4]or 255)
circle(x,y,sz*.08,c)
for i=0,7 do local a=i*pi/4
line(x+cos(a)*sz*.36,y+sin(a)*sz*.36,x+cos(a)*sz*.48,y+sin(a)*sz*.48,c,t)end end
ICON.user=function(x,y,sz,c)safeDraw("Circle",x,y-sz*.17,sz*.18,rgb(c),1,20,c[4]or 255)
safeDraw("Circle",x,y-sz*.17,sz*.16,rgb(c),1,20,c[4]or 255)
outline(x-sz*.3,y+sz*.05,sz*.6,sz*.32,c,sz*.16,255,1.5)end

local function chev(window,x,y,sz,c,angle)
    local a=(angle or 0)*pi/180
local pts={{-sz*.18,-sz*.3},{sz*.12,0},{-sz*.18,sz*.3}}
local out={}
    for i,p in ipairs(pts)do out[i]={x+p[1]*cos(a)-p[2]*sin(a),y+p[1]*sin(a)+p[2]*cos(a)}end
    line(out[1][1],out[1][2],out[2][1],out[2][2],c,max(1.5,sz*.13))
line(out[2][1],out[2][2],out[3][1],out[3][2],c,max(1.5,sz*.13))
end
local function chevDown(x,y,sz,c,up)local h=up and-sz*.16 or sz*.16
local w=sz*.3
line(x-w,y-h*.5,x,y+h*.5,c,max(1.5,sz*.13))
line(x,y+h*.5,x+w,y-h*.5,c,max(1.5,sz*.13))end

function Window:_sx(v)return self.x+v*self.scale end
function Window:_sy(v)return self.y+v*self.scale end
function Window:_sp(v)return v*self.scale end
function Window:_hit(x,y,w,h)return Input.mx>=x and Input.mx<x+w and Input.my>=y and Input.my<y+h end
function Window:_consume()self._consumed=true end
function Window:_canMainClick()return Input.click and not self._consumed and not self:_hasPopup()end
function Window:_color(key)return self.theme[key]or MODERN[key]or MODERN.text end
function Window:_fill(role,x,y,w,h,key,r,a)
    local c=glassColor(self,role,self:_color(key))
rect(x,y,w,h,c,r,a or alphaFor(self,role,c[4]or 255))
end
function Window:_out(x,y,w,h,r,t,c,a)outline(x,y,w,h,c or self.outlineColor,r,a or alphaFor(self,"outline",255),(t or self.borderThickness)*self.outlineStrength)end
function Window:_text(t,x,y,key,size,a)text(t,x,y,self:_color(key),size or 16,"Verdana",a)end
function Window:_textC(t,x,cy,key,size,a)textC(t,x,cy,self:_color(key),size or 16,"Verdana",a)end
function Window:_icon(name,x,y,sz,key)if ICON[name]then ICON[name](x,y,sz,self:_color(key or"icon"))else safeDraw("Circle",x,y,sz*.2,rgb(self:_color(key or"icon")),1,20,255)end end
function Window:_hasPopup()return self.openDrop or self.keyMenu or self.colorPopup or self.configPopup or self.groupPopup or self.accountOpen end
function Window:_closePopups()self.openDrop=nil
self.keyMenu=nil
self.colorPopup=nil
self.configPopup=nil
self.groupPopup=nil
self.accountOpen=false
self.searchOpen=false
self.searchEdit=nil
return self end

function Window:_focusInput(c)
    if not c or c.type~="input"then return end
self.inputEdit={control=c,cursor=#tostring(c.value or""),original=tostring(c.value or""),repeatState={},blink=nowMs(),mouseLatch=Input.left}
self.captureBind=nil
end
function Window:_insertInput(ed,ch)
    local c=ed.control
local s=tostring(c.value or"")
local p=clamp(ed.cursor or#s,0,#s)
local candidate=sub(s,1,p)..ch..sub(s,p+1)
    if c.numeric then if ch:match("%d")then elseif ch=="."and c.allowFloat~=false and not find(s,".",1,true)then elseif ch=="-"and c.allowNegative~=false and p==0 and not find(s,"-",1,true)then else return end end
    if c.maxLength and c.maxLength>0 and#candidate>c.maxLength then return end
c:Set(candidate)
ed.cursor=p+#ch
ed.blink=nowMs()
end
function Window:_processInputEdit()
    local ed=self.inputEdit
if not ed then return end
local c=ed.control
if not alive(c)or c.visible==false or c.disabled then self.inputEdit=nil
return end
    if ed.mouseLatch then if Input.left then return end
ed.mouseLatch=false
ed.repeatState={}end
    local function rep(id,down,delay,rate)return repeater(ed.repeatState,id,down,delay,rate)end
    if rep("escape",anyKey("escape","ESCAPE",27),9999,9999)then c:Set(ed.original,true)
self.inputEdit=nil
return end
    if rep("enter",anyKey("enter","ENTER",13),9999,9999)then c:Submit()
if c.blurOnSubmit~=false then self.inputEdit=nil else ed.original=c.value end
return end
    local s=tostring(c.value or"")
    if rep("back",anyKey("backspace","BACKSPACE","back","BACK",8))then local p=clamp(ed.cursor or#s,0,#s)
if p>0 then c:Set(sub(s,1,p-1)..sub(s,p+1))
ed.cursor=p-1 end
ed.blink=nowMs()
s=tostring(c.value or"")end
    if rep("delete",anyKey("delete","DELETE","del","DEL",46))then local p=clamp(ed.cursor or#s,0,#s)
if p<#s then c:Set(sub(s,1,p)..sub(s,p+2))end
ed.blink=nowMs()
s=tostring(c.value or"")end
    if rep("left",anyKey("left","LEFT",37))then ed.cursor=max(0,(ed.cursor or#s)-1)
ed.blink=nowMs()end
    if rep("right",anyKey("right","RIGHT",39))then ed.cursor=min(#s,(ed.cursor or#s)+1)
ed.blink=nowMs()end
    if rep("home",anyKey("home","HOME",36),9999,9999)then ed.cursor=0
ed.blink=nowMs()end
    if rep("end",anyKey("end","END",35),9999,9999)then ed.cursor=#s
ed.blink=nowMs()end
    local ctrl=anyKey("ctrl","CTRL",162,163)
local shift=anyKey("shift","SHIFT",160,161)
    if not ctrl then for _,q in ipairs(CHAR_KEYS)do if rep(q[1],keyState(q[2]))then self:_insertInput(ed,shift and q[4]or q[3])end end end
end
function Window:_processSearch()
    if not self.searchOpen then return end
self.searchEdit=self.searchEdit or{repeatState={},blink=nowMs()}
local ed=self.searchEdit
    local function rep(id,down,delay,rate)return repeater(ed.repeatState,id,down,delay,rate)end
    if rep("escape",anyKey("escape","ESCAPE",27),9999,9999)then self.searchOpen=false
self.search=""
self.searchEdit=nil
return end
    if rep("back",anyKey("backspace","BACKSPACE",8))then self.search=sub(self.search,1,max(0,#self.search-1))
ed.blink=nowMs()end
    local ctrl=anyKey("ctrl","CTRL",162,163)
local shift=anyKey("shift","SHIFT",160,161)
if not ctrl then for _,q in ipairs(CHAR_KEYS)do if rep(q[1],keyState(q[2]))then self.search=self.search..(shift and q[4]or q[3])
ed.blink=nowMs()end end end
end
function Window:_processBindCapture()
    local c=self.captureBind
if not c then return end
if not alive(c)then self.captureBind=nil
return end
    if self._captureFrame and E.paintCount<=self._captureFrame then return end
    local choices={{"Mouse1",1},{"Mouse2",2},{"Mouse3",4},{"Mouse4",5},{"Mouse5",6}}
    for _,q in ipairs(choices)do if keyState(q[2])then if not c.keyboardOnly then c:SetKey(q[1],q[1])end
self.captureBind=nil
return end end
    for _,k in ipairs(POLL)do if Input.pressed[k]then if k=="Escape"or k=="Backspace"then c:ClearKey()elseif sub(k,1,5)~="Mouse"or not c.keyboardOnly then c:SetKey(k,k)end
self.captureBind=nil
return end end
end
function Window:_updateKeybinds()
    self:ForEachControl(function(c)
        local list={}
if c.type=="keybind"then list[#list+1]=c end
if c.keybind then list[#list+1]=c.keybind end
        for _,k in ipairs(list)do local down=false
if k.key then down=nativeKey(tostring(k.key))end
if k.mode=="Always"then k.active=true elseif k.mode=="Hold"then k.active=down elseif k.mode=="Toggle"then if down and not k.last then k.active=not k.active end
k.last=down end end
    end)
end

local function ctrlRightReserve(c,F)
    if c.type=="toggle"then local w=F.togW
if c.colorPicker then w=w+F.sw+12 end
if c.keybind then w=w+F.dots*2+F.dotsGap+12 end
return w
    elseif c.type=="color"then return F.sw
    elseif c.type=="keybind"then return c:GetPickerWidth(F.keyMax)+F.dots*2+F.dotsGap
    elseif c.type=="slider"or c.type=="dropdown"or c.type=="multiselect"or c.type=="input"then return F.ctrlW
    elseif c.type=="value"then return min(F.ctrlW,190)
    end
    return 0
end
function Window:_controlHeight(c,w,F)
    if c.type=="spacer"then return c.height*self.scale end
    if c.type=="separator"then return 42*self.scale end
    local base=F.rowH*self.scale
    if c.type=="label"then local maxW=max(10,w-(F.padL+F.padR)*self.scale)
local lines=wrapText(c.label,maxW,(c.fontSize or F.font)*self.scale,"Verdana",c.maxLines)
return max(48*self.scale,#lines*(c.lineHeight or 19)*self.scale+24*self.scale)end
    if c.type=="button"then local maxW=max(10,w-(F.padL+F.padR+24)*self.scale)
local lines=wrapText(c.label,maxW,17*self.scale,"Verdana",c.maxLines or 3)
return max(base,#lines*19*self.scale+24*self.scale)end
    if c.type=="buttonpair"then local half=(w-(F.padL+F.padR+8)*self.scale)/2
local l=wrapText(c.leftText,max(10,half-18*self.scale),17*self.scale,"Verdana",3)
local r=wrapText(c.rightText,max(10,half-18*self.scale),17*self.scale,"Verdana",3)
return max(base,max(#l,#r)*19*self.scale+24*self.scale)end
    if c.wrap and c.label~=""then local reserve=ctrlRightReserve(c,F)*self.scale
local maxW=max(10,w-(F.padL+F.padR)*self.scale-reserve-12*self.scale)
local lines=wrapText(c.label,maxW,(c.fontSize or F.font)*self.scale,"Verdana",c.maxLines)
return max(base,#lines*(c.lineHeight or 19)*self.scale+22*self.scale)end
    return base
end

function Window:_sectionControlLayout(section,cardX,cardY,cardW)
    local F=REF.Full
local cols=clamp(section.columns or 1,1,4)
local gap=(section.controlGap or 12)*self.scale
local innerW=cardW
local cellW=(innerW-gap*(cols-1))/cols
    local visible={}
for _,c in ipairs(section.controls)do if alive(c)and visibilityPass(c)then visible[#visible+1]=c end end
    local occupied={}
local autoIndex=0
    for _,c in ipairs(visible)do
        local col=floor(tonumber(c.column)or 0)
local row=floor(tonumber(c.row)or 0)
local span=clamp(floor(tonumber(c.span)or 1),1,cols)
        if col<1 or row<1 then autoIndex=autoIndex+1
row=floor((autoIndex-1)/cols)+1
col=((autoIndex-1)%cols)+1 end
        if col>cols then col=cols end
if col+span-1>cols then span=cols-col+1 end
        c._gridCol,c._gridRow,c._gridSpan=col,row,span
occupied[row]=occupied[row]or{}
occupied[row][#occupied[row]+1]=c
    end
    local rows={}
for r in pairs(occupied)do rows[#rows+1]=r end
sort(rows)
    local y=cardY
local layouts={}
local contentH=0
    for _,r in ipairs(rows)do local rh=0
for _,c in ipairs(occupied[r])do local cw=cellW*c._gridSpan+gap*(c._gridSpan-1)
rh=max(rh,self:_controlHeight(c,cw,F))end
for _,c in ipairs(occupied[r])do local x=cardX+(c._gridCol-1)*(cellW+gap)
local cw=cellW*c._gridSpan+gap*(c._gridSpan-1)
layouts[c]={x=x,y=y,w=cw,h=rh}end
y=y+rh
contentH=contentH+rh end
    return layouts,contentH,rows,cellW,gap
end

function Window:_buildLayout(tab)
    local s=self.scale
    local panel=self.kind=="Panel"or self.tabBarVisible==false
    local bodyX=panel and(self.x+18*s)or self:_sx(REF.ContentX)
    local bodyY=panel and(self.y+72*s)or self:_sy(REF.ContentTop)
    local fullBodyW=panel and((self.width-36)*s)or((self.width-REF.ContentX-REF.RightMargin)*s)
    local bodyH=panel and((self.height-90)*s)or((self.height-REF.ContentTop-15)*s)
    local preview=nil
local bodyW=fullBodyW
    if tab and alive(tab.dockedPreview) and tab.dockedPreview.visible~=false and tab.dockedPreview.docked~=false then
        local dp=tab.dockedPreview
local gap=(dp.dockGap or REF.ColumnGap)*s
local pw=clamp(fullBodyW*(dp.dockWidthRatio or .36),260*s,480*s)
bodyW=max(320*s,fullBodyW-pw-gap)
preview={x=bodyX+bodyW+gap,y=bodyY,w=pw,h=bodyH}
    end
    local cols=clamp(self.columns,1,4)
local gap=REF.ColumnGap*s
local colW=(bodyW-gap*(cols-1))/cols
    local sections={}
local rowsMap={}
    for _,sec in ipairs(tab.sections)do if alive(sec)and visibilityPass(sec)then local row=max(1,floor(sec.row or 1))
rowsMap[row]=rowsMap[row]or{}
rowsMap[row][#rowsMap[row]+1]=sec end end
    local rowNums={}
for r in pairs(rowsMap)do rowNums[#rowNums+1]=r end
sort(rowNums)
    local y=bodyY-(tab.pageScroll or 0)
local contentBottom=bodyY
    for ri,row in ipairs(rowNums)do
        local rowSecs=rowsMap[row]
local rowH=0
local pre={}
        for _,sec in ipairs(rowSecs)do
            local col=clamp(floor(sec.column or 1),1,cols)
local span=clamp(floor(sec.span or 1),1,cols-col+1)
local x=bodyX+(col-1)*(colW+gap)
local w=colW*span+gap*(span-1)
            local layouts,contentH=self:_sectionControlLayout(sec,x,y+30*s,w)
local total
            if sec.sizeMode=="fixed"then total=max(30*s+63*s,(tonumber(sec.height)or 240)*s)
            elseif sec.sizeMode=="fill"then total=max(30*s+63*s,(bodyY+bodyH-y))
            else total=30*s+contentH end
            if sec.minHeight then total=max(total,sec.minHeight*s)end
if sec.maxHeight then total=min(total,sec.maxHeight*s)end
            pre[#pre+1]={sec=sec,x=x,w=w,layouts=layouts,contentH=contentH,total=total}
rowH=max(rowH,total)
        end
        for _,p in ipairs(pre)do
            local sec=p.sec
local total=p.total
if sec.sizeMode=="fill"then total=rowH end
local cardY=y+30*s
local cardH=max(0,total-30*s)
local maxScroll=max(0,p.contentH-cardH)
sec.maxScroll=maxScroll
sec.scrollTarget=clamp(sec.scrollTarget or 0,0,maxScroll)
if self.smoothScroll then sec.scroll=(sec.scroll or 0)+(sec.scrollTarget-(sec.scroll or 0))*min(1,dt()*self.scrollSpeed)else sec.scroll=sec.scrollTarget end
sec.resolvedHeight=total/s
            sections[#sections+1]={section=sec,x=p.x,y=y,w=p.w,h=total,cardY=cardY,cardH=cardH,layouts=p.layouts,contentH=p.contentH}
contentBottom=max(contentBottom,y+total)
        end
        y=y+rowH+REF.SectionGap*s
contentBottom=max(contentBottom,y)
    end
    local contentH=max(0,contentBottom-bodyY-(#rowNums>0 and REF.SectionGap*s or 0))
tab.maxScroll=max(0,contentH-bodyH)
if self.mainScrollEnabled~=false and tab.mainScrollEnabled~=false then tab.pageTarget=clamp(tab.pageTarget or 0,0,tab.maxScroll)else tab.pageTarget=0 end
if self.smoothScroll then tab.pageScroll=(tab.pageScroll or 0)+(tab.pageTarget-(tab.pageScroll or 0))*min(1,dt()*self.scrollSpeed)else tab.pageScroll=tab.pageTarget end
    self._layout={bodyX=bodyX,bodyY=bodyY,bodyW=bodyW,fullBodyW=fullBodyW,bodyH=bodyH,sections=sections,contentH=contentH,maxScroll=tab.maxScroll,preview=preview}
return self._layout
end

local function intersectY(y,h,top,bottom)local y2=max(y,top)
local b=min(y+h,bottom)
return y2,max(0,b-y2),y2==y and b==y+h end

function Window:_drawWrapped(lines,x,y,c,size,lineH,center,w)
    for i,l in ipairs(lines)do local xx=x
if center then local tw=measure(l,size,"Verdana")
xx=x+(w-tw)*.5 end
text(l,xx,y+(i-1)*lineH,c,size,"Verdana")end
end
function Window:_drawToggle(x,cy,on,disabled)
    local s=self.scale
local F=REF.Full
local w,h=F.togW*s,F.togH*s
local xx=x-w
local col=on and self:_color("accent")or self:_color("toggleTrack")
if disabled then col=blend(col,self:_color("menuBg"),.45)end
rect(xx,cy-h*.5,w,h,col,h*.5,alphaFor(self,"control",255))
local pad=(h-F.knob*s)*.5
local kx=on and(xx+w-pad-F.knob*s*.5)or(xx+pad+F.knob*s*.5)
circle(kx,cy,F.knob*s*.5,on and self:_color("white")or self:_color("toggleKnob"))
    return xx,cy-h*.5,w,h
end
function Window:_keyLabel(k)return self.captureBind==k and"..."or((k.keyLabel and k.keyLabel~="")and tostring(k.keyLabel)or(k.key and tostring(k.key):upper()or"None"))end
function Window:_drawKeybox(k,right,cy,F,interactive,leftBound)
    local s=self.scale
local label=self:_keyLabel(k)
local tw=measure(label,F.keyFont*s,"Verdana")
local dotsTotal=(F.dotsGap+F.dots*2)*s
local maxW=leftBound and max(34*s,right-leftBound-dotsTotal)or F.keyMax*s
local w=min(maxW,F.keyMax*s,max(F.keyMin*s,tw+F.keyPad*2*s))
local h=F.keyH*s
local x=right-w
local y=cy-h*.5
local hov=self:_hit(x,y,w,h)
self:_fill("control",x,y,w,h,hov and"controlHover"or"control",F.keyR*s)
if self.captureBind==k then self:_out(x,y,w,h,F.keyR*s,1,self:_color("accent"),255)end
textC(label,x+(w-tw)*.5,cy,self.captureBind==k and self:_color("accent")or self:_color("text"),F.keyFont*s,"Verdana")
local dx=x-F.dotsGap*s-F.dots*s*.5
ICON.dots(dx,cy,F.dots*s,(self.keyMenu and self.keyMenu.control==k)and self:_color("text")or self:_color("muted"))
local dhx,dhy,dhs=dx-F.dots*s,cy-F.dots*s,F.dots*2*s
    if interactive and Input.click and not self._consumed and not self:_hasPopup()then if self:_hit(x,y,w,h)then self.captureBind=k
self._captureFrame=E.paintCount
self.inputEdit=nil
self:_consume()elseif self:_hit(dhx,dhy,dhs,dhs)then self.keyMenu={control=k,x=x,y=y+h+6*s,w=max(160*s,w),h=5*REF.Compact.itemH*s}
self:_consume()end end
    if interactive and Input.rightClick and not self._consumed and not self:_hasPopup()and self:_hit(x,y,w,h)then self.keyMenu={control=k,x=x,y=y+h+6*s,w=max(160*s,w),h=5*REF.Compact.itemH*s}
self:_consume()end
    return x-F.dotsGap*s-F.dots*2*s,y,w+F.dotsGap*s+F.dots*2*s,h
end
function Window:_drawColorChip(c,right,cy,F,interactive)
    local s=self.scale
local sz=F.sw*s
local x=right-sz
local y=cy-sz*.5
rect(x,y,sz,sz,c.value,F.swR*s,c.value[4]or 255)
outline(x,y,sz,sz,self:_color("white"),F.swR*s,42,1.5*s)
if interactive and Input.click and not self._consumed and not self:_hasPopup()and self:_hit(x,y,sz,sz)then self.colorPopup={control=c,x=x+sz-300*s,y=y+sz+8*s,w=300*s}
self:_consume()end
return x,y,sz,sz
end


function Window:_sliderDisplay(c,v)if type(c.format)=="function"then local ok,q=pcall(c.format,v,c)
if ok then return tostring(q)end end
return c.float and format("%.2f",v)or tostring(round(v))end
function Window:_startSliderEdit(c,rectv)
    self.sliderEdit={control=c,text=tostring(c.value or""),original=c.value,rect=rectv,repeatState={},blink=nowMs(),cursor=#tostring(c.value or"")}
self.inputEdit=nil
end
function Window:_processSliderEdit()
    local ed=self.sliderEdit
if not ed then return end
local c=ed.control
if not alive(c)then self.sliderEdit=nil
return end
    local function rep(id,down,delay,rate)return repeater(ed.repeatState,id,down,delay,rate)end
    if rep("escape",anyKey("escape","ESCAPE",27),9999,9999)then self.sliderEdit=nil
return end
    if rep("enter",anyKey("enter","ENTER",13),9999,9999)then local n=tonumber(ed.text)
if n then c:Set(n)end
self.sliderEdit=nil
return end
    if rep("back",anyKey("backspace","BACKSPACE",8))then local p=clamp(ed.cursor,0,#ed.text)
if p>0 then ed.text=sub(ed.text,1,p-1)..sub(ed.text,p+1)
ed.cursor=p-1 end
ed.blink=nowMs()end
    if rep("delete",anyKey("delete","DELETE",46))then local p=clamp(ed.cursor,0,#ed.text)
if p<#ed.text then ed.text=sub(ed.text,1,p)..sub(ed.text,p+2)end
ed.blink=nowMs()end
    if rep("left",anyKey("left","LEFT",37))then ed.cursor=max(0,ed.cursor-1)
ed.blink=nowMs()end
if rep("right",anyKey("right","RIGHT",39))then ed.cursor=min(#ed.text,ed.cursor+1)
ed.blink=nowMs()end
    local shift=anyKey("shift","SHIFT",160,161)
for _,q in ipairs(CHAR_KEYS)do if repeater(ed.repeatState,q[1],keyState(q[2]))then local ch=shift and q[4]or q[3]
if ch:match("[%d%.%-]")then local p=ed.cursor
ed.text=sub(ed.text,1,p)..ch..sub(ed.text,p+1)
ed.cursor=p+1
ed.blink=nowMs()end end end
end
function Window:_openDropdown(c,x,y,w,h)
    self.openDrop={control=c,x=x,y=y+h+6*self.scale,w=w,scroll=c.dropdownScroll or 0}
self.keyMenu=nil
self.colorPopup=nil
self.configPopup=nil
self.groupPopup=nil
self.accountOpen=false
end
function Window:_drawControl(c,r,clipTop,clipBottom)
    if not alive(c)or not visibilityPass(c)then return end
    local y,h,fully=intersectY(r.y,r.h,clipTop,clipBottom)
if h<=1 then return end
    local s=self.scale
local F=REF.Full
local left=r.x+F.padL*s
local right=r.x+r.w-F.padR*s
local cy=r.y+r.h*.5
local interactive=fully and not c.disabled
    local hov=fully and self:_hit(r.x,r.y,r.w,r.h)and not self:_hasPopup()
    if hov and c.rowHover==true and c.type~="spacer"and c.type~="separator"then rect(r.x,r.y,r.w,r.h,self:_color("rowHover"),0,alphaFor(self,"card",255))end
    if c.type=="spacer"then return end
    if c.type=="separator"then
        local label=fit(upper(c.label),max(20,right-left-18*s),13*s,"Verdana")
local tw=measure(label,13*s,"Verdana")
textC(label,left,cy,self:_color("muted"),13*s,"Verdana")
line(left+tw+12*s,cy,right,cy,self:_color("line"),1*s,36)
return
    end
    if c.type=="label"then
        local lines=wrapText(c.label,max(10,r.w-(F.padL+F.padR)*s),(c.fontSize or F.font)*s,"Verdana",c.maxLines)
local lh=(c.lineHeight or 19)*s
self:_drawWrapped(lines,left,r.y+(r.h-#lines*lh)*.5,self:_color("text"),(c.fontSize or F.font)*s,lh,false)
return
    end
    if c.type=="button"then
        local bx,by,bw,bh=left,r.y+11*s,right-left,r.h-22*s
local bhov=interactive and self:_hit(bx,by,bw,bh)
self:_fill("control",bx,by,bw,bh,bhov and"controlHover"or"control",10*s)
self:_out(bx,by,bw,bh,10*s,.75,self:_color("outline"),110)
local lines=wrapText(c.label,max(10,bw-24*s),17*s,"Verdana",3)
local lh=19*s
self:_drawWrapped(lines,bx,by+(bh-#lines*lh)*.5,self:_color("text"),17*s,lh,true,bw)
if interactive and Input.click and not self._consumed and not self:_hasPopup()and self:_hit(bx,by,bw,bh)then self:_consume()
if type(c.fn)=="function"then pcall(c.fn,c)end end
return
    end
    if c.type=="buttonpair"then
        local gap=8*s
local bw=(right-left-gap)*.5
local by=r.y+11*s
local bh=r.h-22*s
local function one(x,w,label,fn)local q=self:_hit(x,by,w,bh)
self:_fill("control",x,by,w,bh,q and"controlHover"or"control",10*s)
self:_out(x,by,w,bh,10*s,.75,self:_color("outline"),110)
local lines=wrapText(label,max(10,w-18*s),17*s,"Verdana",3)
local lh=19*s
self:_drawWrapped(lines,x,by+(bh-#lines*lh)*.5,self:_color("text"),17*s,lh,true,w)
if interactive and Input.click and not self._consumed and not self:_hasPopup()and q then self:_consume()
if type(fn)=="function"then pcall(fn,c)end end end
one(left,bw,c.leftText,c.leftFn)
one(left+bw+gap,bw,c.rightText,c.rightFn)
return
    end
    local reserve=min(ctrlRightReserve(c,F)*s,max(0,(right-left)*.60))
local labelMax=max(10,right-left-reserve-12*s)
local labelLines
    if c.wrap then labelLines=wrapText(c.label,labelMax,(c.fontSize or F.font)*s,"Verdana",c.maxLines)else labelLines={fit(c.label,labelMax,(c.fontSize or F.font)*s,"Verdana")}end
    local lh=(c.lineHeight or 19)*s
self:_drawWrapped(labelLines,left,r.y+(r.h-#labelLines*lh)*.5,self:_color(c.disabled and"muted"or"text"),(c.fontSize or F.font)*s,lh,false)

    if c.type=="toggle"then
        local accessoryRight=right
        if c.colorPicker then self:_drawColorChip(c.colorPicker,accessoryRight,cy,F,interactive)
accessoryRight=accessoryRight-F.sw*s-12*s end
        if c.keybind then accessoryRight=self:_drawEmbeddedKeybindDots(c,accessoryRight,cy,F,interactive)-12*s end
        local tx,ty,tw,th=self:_drawToggle(accessoryRight,cy,c.value,c.disabled)
        if interactive and Input.click and not self._consumed and not self:_hasPopup()and self:_hit(tx,ty,tw,th)then c:Set(not c.value)
self:_consume()end
    elseif c.type=="dropdown"or c.type=="multiselect"then
        if c.optionsSource then c:RefreshOptionsSource(false)end
local fw=min(F.ctrlW*s,max(64*s,(right-left)*.56))
local fh=F.ddH*s
local x=right-fw
local yy=cy-fh*.5
local open=self.openDrop and self.openDrop.control==c
local dh=self:_hit(x,yy,fw,fh)
self:_fill("control",x,yy,fw,fh,(dh or open)and"controlHover"or"control",F.ddR*s)
local label=c.type=="multiselect"and c:GetSummary()or tostring(c:Get()or"None")
local maxW=fw-(F.ddPadL+F.ddPadR+F.chev+6)*s
textC(fit(label,maxW,F.ddFont*s,"Verdana"),x+F.ddPadL*s,cy,self:_color("text"),F.ddFont*s,"Verdana")
chevDown(x+fw-F.ddPadR*s-F.chev*s*.5,cy,F.chev*s,self:_color("chev"),open)
        if interactive and Input.click and not self._consumed and dh and(not self:_hasPopup()or open)then
            if open then self.openDrop=nil else self:_openDropdown(c,x,yy,fw,fh)end
            self:_consume()
        end
    elseif c.type=="slider"then
        local display=self:_sliderDisplay(c,c.value)
local editing=self.sliderEdit and self.sliderEdit.control==c
local shown=editing and self.sliderEdit.text or display
local tw=measure(shown,F.valFont*s,"Verdana")
local vw=max((editing and 64 or 0)*s,tw+F.valPad*2*s)
local vh=F.valH*s
local vx=right-vw
local vy=cy-vh*.5
local ctrlW=min(F.ctrlW*s,max(86*s,(right-left)*.58))
local trackX=right-ctrlW
local trackW=max(20*s,vx-F.sGap*s-trackX)
local trackY=cy-2*s
self:_fill("control",trackX,trackY,trackW,4*s,"control",2*s)
local range=max(.00001,c.max-c.min)
local p=clamp((clamp(c.value,c.min,c.max)-c.min)/range,0,1)
local usable=max(1,trackW-F.sKnob*s)
local kx=trackX+F.sKnob*s*.5+p*usable
rect(trackX,trackY,max(0,kx-trackX),4*s,self:_color("accent"),2*s,255)
circle(kx,cy,F.sKnob*s*.5+1*s,self:_color("black"),70)
circle(kx,cy,F.sKnob*s*.5,self:_color("white"),255)
        if self.activeSlider==c then if Input.left then local np=clamp((Input.mx-trackX-F.sKnob*s*.5)/usable,0,1)
c:Set(c.min+np*(c.max-c.min))else self.activeSlider=nil end end
        if interactive and Input.click and not self._consumed and not self:_hasPopup()and self:_hit(trackX,cy-16*s,trackW,32*s)then self.activeSlider=c
local np=clamp((Input.mx-trackX-F.sKnob*s*.5)/usable,0,1)
c:Set(c.min+np*(c.max-c.min))
self:_consume()end
        local vhv=self:_hit(vx,vy,vw,vh)
self:_fill("control",vx,vy,vw,vh,(editing or vhv)and"controlHover"or"control",F.valR*s)
if editing then self:_out(vx,vy,vw,vh,F.valR*s,1,self:_color("accent"),255)
local pre=sub(shown,1,self.sliderEdit.cursor or#shown)
local ex=floor(vx+(vw-tw)*.5)
local preW=caretWidth(pre,F.valFont*s,"Verdana")
textC(shown,ex,cy,self:_color("text"),F.valFont*s,"Verdana")
if(nowMs()-(self.sliderEdit.blink or 0))%900<450 then
    local cx=clamp(ex+floor(preW+.5),floor(vx+2*s),floor(vx+vw-2*s))
    caretLine(cx,cy,shown,F.valFont*s,"Verdana",self:_color("text"),255)
end else textC(display,vx+(vw-tw)*.5,cy,self:_color("text"),F.valFont*s,"Verdana")end
        if interactive and Input.click and not self._consumed and not self:_hasPopup()and vhv then self:_startSliderEdit(c,{vx,vy,vw,vh})
self:_consume()end
    elseif c.type=="input"then
        self:_drawFawnInput(c,r,right,cy,F,interactive)
    elseif c.type=="keybind"then self:_drawKeybox(c,right,cy,F,interactive,left)
    elseif c.type=="color"then self:_drawColorChip(c,right,cy,F,interactive)
    elseif c.type=="value"then
        local v=tostring(resolve(c.valueSource,c)or"")
local maxW=min(F.ctrlW*s,(right-left)*.48)
local lines=c.wrap and wrapText(v,maxW,F.valFont*s,"Verdana",c.maxLines or 2)or{fit(v,maxW,F.valFont*s,"Verdana")}
local col=c.valueAccent and self:_color("accent")or(c.valueMuted and self:_color("muted")or self:_color("text"))
local yy=r.y+(r.h-#lines*lh)*.5
for i,l in ipairs(lines)do local tw=measure(l,F.valFont*s,"Verdana")
text(l,right-tw,yy+(i-1)*lh,col,F.valFont*s,"Verdana")end
    end
end

function Window:_drawSection(box,bodyTop,bodyBottom)
    local sec=box.section
local s=self.scale
local titleY=box.y+7*s
if titleY>=bodyTop-20*s and titleY<=bodyBottom then textC(upper(sec.name),box.x+22*s,titleY,self:_color("muted"),14*s,"Verdana")end
    local cardTop=box.cardY
local cardH=box.cardH
local cy,ch,full=intersectY(cardTop,cardH,bodyTop,bodyBottom)
if ch<=1 then return end
    self:_fill("card",box.x,cy,box.w,ch,"card",full and 14*s or 0)
if full then self:_out(box.x,cardTop,box.w,cardH,14*s,.8,self:_color("outline"),100)else line(box.x,cy,box.x+box.w,cy,self:_color("outline"),1*s,90)
line(box.x,cy+ch,box.x+box.w,cy+ch,self:_color("outline"),1*s,90)end
    local offset=sec.scroll or 0
local rows={}
for c,r in pairs(box.layouts)do rows[#rows+1]={c=c,r=r}end
sort(rows,function(a,b)if a.r.y==b.r.y then return a.r.x<b.r.x end return a.r.y<b.r.y end)
    local lastY=nil
for _,q in ipairs(rows)do local r={x=q.r.x,y=q.r.y-offset,w=q.r.w,h=q.r.h}
if lastY and abs(r.y-lastY)>1 then line(box.x,max(cardTop,r.y),box.x+box.w,min(cardTop+cardH,r.y),self:_color("line"),1,18)end
self:_drawControl(q.c,r,max(cardTop,bodyTop),min(cardTop+cardH,bodyBottom))
lastY=r.y+r.h end
    if sec.columns and sec.columns>1 then local gap=(sec.controlGap or 12)*s
local innerW=box.w
local cw=(innerW-gap*(sec.columns-1))/sec.columns
for i=1,sec.columns-1 do local x=box.x+i*cw+(i-.5)*gap
line(x,max(cardTop,bodyTop)+8*s,x,min(cardTop+cardH,bodyBottom)-8*s,self:_color("line"),1,14)end end
    if sec.maxScroll>1 then local trackX=box.x+box.w-7*s
local top=max(cardTop,bodyTop)+7*s
local bh=min(cardTop+cardH,bodyBottom)-top-7*s
if bh>20*s then local thumb=max(28*s,bh*(cardH/max(cardH,box.contentH)))
local span=max(1,bh-thumb)
local ratio=(sec.scroll or 0)/sec.maxScroll
local ty=top+span*ratio
rect(trackX,top,2*s,bh,self:_color("control"),1*s,140)
rect(trackX-1*s,ty,4*s,thumb,self:_color("outline"),2*s,220)
if Input.click and not self._consumed and not self:_hasPopup()and self:_hit(trackX-6*s,ty-3*s,14*s,thumb+6*s)then sec._scrollDrag={top=top,span=span,off=Input.my-ty}
self:_consume()end
if sec._scrollDrag then if Input.left then local rr=clamp((Input.my-sec._scrollDrag.top-sec._scrollDrag.off)/sec._scrollDrag.span,0,1)
sec.scrollTarget=rr*sec.maxScroll else sec._scrollDrag=nil end end end end
end

function Window:_drawContent()
    local tab=self:_activeTab()
if not tab then return end
local layout=self:_buildLayout(tab)
local top,bottom=layout.bodyY,layout.bodyY+layout.bodyH
    local pointerBody=self:_hit(layout.bodyX,top,layout.bodyW,layout.bodyH)
    local wheelOwned=false
    for _,box in ipairs(layout.sections)do
        local sec=box.section
if sec.maxScroll>1 and self:_hit(box.x,max(box.cardY,top),box.w,min(box.cardH,bottom-max(box.cardY,top)))and Input.wheel~=0 and not self:_hasPopup()then sec:ScrollBy(Input.wheel*sec:GetScrollStep())
wheelOwned=true
break end
    end
    if not wheelOwned and pointerBody and Input.wheel~=0 and not self:_hasPopup()and tab.maxScroll>0 then tab:ScrollBy(Input.wheel*tab:GetScrollStep())end
    for _,box in ipairs(layout.sections)do if box.y+box.h>=top and box.y<=bottom then self:_drawSection(box,top,bottom)end end
    if layout.preview and alive(tab.dockedPreview) then tab.dockedPreview:_renderDocked(layout.preview) end
    if #layout.sections==0 then local h=220*self.scale
self:_fill("card",layout.bodyX,top,layout.bodyW,h,"card",14*self.scale)
self:_out(layout.bodyX,top,layout.bodyW,h,14*self.scale,.8,self:_color("outline"),100)
local msg="No settings on this tab yet"
local tw,th=measure(msg,18*self.scale,"Verdana")
text(msg,layout.bodyX+(layout.bodyW-tw)*.5,top+(h-th)*.5,self:_color("muted"),18*self.scale,"Verdana")end
    if tab.maxScroll>1 then local tx=layout.bodyX+layout.bodyW-5*self.scale
local th=layout.bodyH-8*self.scale
local ty=top+4*self.scale
local thumb=max(32*self.scale,th*(layout.bodyH/(layout.contentH)))
local span=max(1,th-thumb)
local rr=(tab.pageScroll or 0)/tab.maxScroll
local yy=ty+span*rr
rect(tx,ty,2*self.scale,th,self:_color("control"),1*self.scale,140)
rect(tx-1*self.scale,yy,4*self.scale,thumb,self:_color("outline"),2*self.scale,230)
if Input.click and not self._consumed and not self:_hasPopup()and self:_hit(tx-6*self.scale,yy-3*self.scale,14*self.scale,thumb+6*self.scale)then tab._pageDrag={top=ty,span=span,off=Input.my-yy}
self:_consume()end
if tab._pageDrag then if Input.left then local v=clamp((Input.my-tab._pageDrag.top-tab._pageDrag.off)/tab._pageDrag.span,0,1)
tab.pageTarget=v*tab.maxScroll else tab._pageDrag=nil end end end
end


-- Final reference renderer and interaction layer
local function iconForTab(t)
    local n=lower(t.icon or t.name or "")
    if n:find("rage",1,true) or n:find("aim",1,true) or n:find("cross",1,true) then return "crosshair" end
    if n:find("visual",1,true) or n:find("image",1,true) then return "image" end
    if n:find("inventory",1,true) or n:find("layer",1,true) then return "layers" end
    if n:find("misc",1,true) or n:find("setting",1,true) then return "misc" end
    if n:find("mouse",1,true) then return "mouse" end
    return t.icon or "misc"
end

function Window:_visibleTabs()
    local out={}
    for _,t in ipairs(self.tabs) do if alive(t) and visibilityPass(t) then out[#out+1]=t end end
    return out
end

function Window:_drawLogo()
    local s=self.scale
    local x,y=self.x+25*s,self.y+20*s
    self:_fill("control",x,y,50*s,50*s,"logoBg",12*s,255)
    if self.logoImage then
        drawImage(self.logoImage,x+5*s,y+5*s,40*s,40*s,1)
    else
        local lw,lh=measure(self.logo,24*s,"Verdana")
        text(self.logo,x+25*s-lw*.5,y+25*s-lh*.5,self:_color("logoFg"),24*s,"Verdana")
    end
    textC(self.brand,self.x+98*s,self.y+37*s,self:_color("white"),22*s,"Verdana")
    textC(self.subtitle,self.x+98*s,self.y+58*s,self:_color("muted"),13*s,"Verdana")
end

function Window:_sidebarGeometry()
    local s=self.scale
    local top=self.y+110*s
    local profileY=self.y+(self.height-70)*s
    return top,profileY
end

function Window:_drawSidebar()
    local s=self.scale
    local X,Y=self.x,self.y
    local sidebarW=REF.Sidebar*s
    self:_fill("sidebar",X,Y,sidebarW,self.height*s,"menuBg",self.corner*s)
    rect(X+sidebarW-1*s,Y,1*s,self.height*s,self:_color("line"),0,30)
    self:_drawLogo()
    line(X+15*s,Y+91*s,X+260*s,Y+91*s,self:_color("line"),1,42)

    local groups={}
    local order={}
    for _,t in ipairs(self:_visibleTabs()) do
        local g=t.group or "MAIN"
        if not groups[g] then groups[g]={}
order[#order+1]=g end
        groups[g][#groups[g]+1]=t
    end

    local navTop,profileY=self:_sidebarGeometry()
    local available=max(80*s,profileY-navTop-18*s)
    local contentH=0
    for _,g in ipairs(order) do contentH=contentH+26*s+#groups[g]*60*s+29*s end
    local maxScroll=max(0,contentH-available)
    self.sidebarTarget=clamp(self.sidebarTarget or 0,0,maxScroll)
    if self.smoothScroll then self.sidebarScroll=(self.sidebarScroll or 0)+(self.sidebarTarget-(self.sidebarScroll or 0))*min(1,dt()*self.scrollSpeed) else self.sidebarScroll=self.sidebarTarget end
    if self:_hit(X,navTop,sidebarW,available) and Input.wheel~=0 and not self:_hasPopup() then self.sidebarTarget=clamp(self.sidebarTarget+Input.wheel*60*s,0,maxScroll) end

    local y=navTop-(self.sidebarScroll or 0)
    for _,g in ipairs(order) do
        if y+20*s>=navTop and y<=navTop+available then textC(upper(g),X+33*s,y+7*s,self:_color("muted"),14*s,"Verdana") end
        y=y+26*s
        for _,tab in ipairs(groups[g]) do
            local ix,iy,iw,ih=X+17*s,y,241*s,55*s
            local visible=iy>=navTop and iy+ih<=navTop+available
            if visible then
                local active=tab==self.activeTab
                local hov=self:_hit(ix,iy,iw,ih) and not self:_hasPopup()
                if active then self:_fill("control",ix,iy,iw,ih,"activeItem",12*s)
                elseif hov then rect(ix,iy,iw,ih,self:_color("white"),12*s,12) end
                self:_icon(iconForTab(tab),X+43*s,iy+27.5*s,22*s,active and"accent"or"icon")
                textC(fit(tab.name,168*s,20*s,"Verdana"),X+72*s,iy+27.5*s,self:_color(active and"white"or"navText"),20*s,"Verdana")
                if Input.click and not self._consumed and not self:_hasPopup() and hov then self:SelectTab(tab)
self:_consume() end
            end
            y=y+60*s
        end
        y=y+29*s
    end

    if maxScroll>0 then
        local tx=X+263*s
local th=available
local thumb=max(32*s,th*(available/contentH))
local span=max(1,th-thumb)
local ty=navTop+span*((self.sidebarScroll or 0)/maxScroll)
        local trackHover=self:_hit(tx-7*s,navTop,15*s,th)
        local thumbHover=self:_hit(tx-7*s,ty-3*s,15*s,thumb+6*s)
        local active=self._sidebarDrag~=nil
        rect(tx,navTop,2*s,th,self:_color(trackHover and"controlHover"or"control"),1*s,trackHover and 190 or 120)
        rect(tx-((active or thumbHover)and 1.5*s or 1*s),ty,(active or thumbHover)and 5*s or 4*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 210)
        if Input.click and not self._consumed and not self:_hasPopup() and thumbHover then self._sidebarDrag={top=navTop,span=span,off=Input.my-ty};self:_consume()end
        if self._sidebarDrag then if Input.left then self.sidebarTarget=clamp((Input.my-self._sidebarDrag.top-self._sidebarDrag.off)/self._sidebarDrag.span,0,1)*maxScroll;self.sidebarScroll=self.sidebarTarget else self._sidebarDrag=nil end end
    else self._sidebarDrag=nil end

    -- erase any partially visible navigation text before the profile/footer region.
    rect(X,profileY-19*s,sidebarW,74*s,self:_color("menuBg"),0,255)
    line(X+15*s,profileY-15*s,X+260*s,profileY-15*s,self:_color("line"),1,42)
    local ux,uy,uw,uh=X+15*s,profileY,245*s,55*s
    local phov=self:_hit(ux,uy,uw,uh) and not(self.openDrop or self.keyMenu or self.colorPopup or self.configPopup or self.groupPopup)
    if phov or self.accountOpen then self:_fill("control",ux,uy,uw,uh,"activeItem",12*s) end
    if self.profileImage then
        self:_fill("control",ux+8*s,uy+8*s,39*s,39*s,"control",19.5*s)
        drawImage(self.profileImage,ux+8*s,uy+8*s,39*s,39*s,1)
    else
        circle(ux+27.5*s,uy+27.5*s,19.5*s,self:_color("avatar"),255)
        circle(ux+27.5*s,uy+22*s,6.5*s,self:_color("avatarDark"),255)
        outline(ux+17*s,uy+31*s,21*s,11*s,self:_color("avatarDark"),6*s,255,2*s)
    end
    textC(fit(self.profileName,139*s,16*s,"Verdana"),ux+58*s,uy+21*s,self:_color("text"),16*s,"Verdana")
    textC(fit(self.profileSubtitle,139*s,12*s,"Verdana"),ux+58*s,uy+39*s,self:_color("muted"),12*s,"Verdana")
    local target=self.accountOpen and 90 or 0
    if self.animations then self.accountAnim=self.accountAnim+(target-self.accountAnim)*min(1,dt()*self.animationSpeed) else self.accountAnim=target end
    chev(self,ux+222*s,uy+27.5*s,16*s,self:_color("muted"),self.accountAnim)
    if Input.click and not self._consumed and phov and not(self.openDrop or self.keyMenu or self.colorPopup or self.configPopup or self.groupPopup) then
        if type(self.profileClick)=="function" then pcall(self.profileClick,self) else self.accountOpen=not self.accountOpen end
        self:_consume()
    end
end

function Window:_drawTopbar()
    local s=self.scale
local X,Y=self.x,self.y
    local left=X+REF.ContentX*s
local top=Y+20*s
local h=50*s
    local configW=min(302*s,max(250*s,(self.width-REF.ContentX-REF.RightMargin)*s*.33))
    local saveW=50*s
    local configX=left+saveW+7*s
    local configCardW=configW-saveW-7*s
    local saveHov=self:_hit(left,top,saveW,h)and not self:_hasPopup()
    self:_fill("control",left,top,saveW,h,saveHov and"controlHover"or"card",12*s)
self:_out(left,top,saveW,h,12*s,.8,self:_color("outline"),105)
    self:_icon("save",left+25*s,top+25*s,21*s,"text")
    if Input.click and not self._consumed and not self:_hasPopup() and saveHov then self:SaveNamedConfig(self.configName)
self:Notify("Saved "..self.configName,{title="CONFIG"})
self:_consume() end

    local cfgHov=self:_hit(configX,top,configCardW,h)and not(self.openDrop or self.keyMenu or self.colorPopup or self.groupPopup or self.accountOpen)
    self:_fill("control",configX,top,configCardW,h,cfgHov and"controlHover"or"card",12*s)
self:_out(configX,top,configCardW,h,12*s,.8,self:_color("outline"),105)
    textC(fit(self.configName,max(20,configCardW-48*s),17*s,"Verdana"),configX+16*s,top+25*s,self:_color("text"),17*s,"Verdana")
    chevDown(configX+configCardW-20*s,top+25*s,14*s,self:_color("chev"),self.configPopup~=nil)
    if Input.click and not self._consumed and cfgHov then
        self.configPopup=self.configPopup and nil or{x=configX,y=top+h+6*s,w=configCardW}
        self.openDrop=nil
self.keyMenu=nil
self.colorPopup=nil
self.groupPopup=nil
self.accountOpen=false
self:_consume()
    end

    local gx=configX+configCardW+25*s
local gw=142*s
    if gx+gw>X+(self.width-REF.RightMargin-70)*s then gw=max(110*s,X+(self.width-REF.RightMargin-70)*s-gx) end
    local ghov=self:_hit(gx,top,gw,h)and not(self.openDrop or self.keyMenu or self.colorPopup or self.configPopup or self.accountOpen)
    self:_fill("control",gx,top,gw,h,ghov and"controlHover"or"card",12*s)
self:_out(gx,top,gw,h,12*s,.8,self:_color("outline"),105)
    textC(fit(self.group,max(20,gw-42*s),16*s,"Verdana"),gx+14*s,top+25*s,self:_color("text"),16*s,"Verdana")
    chevDown(gx+gw-18*s,top+25*s,13*s,self:_color("chev"),self.groupPopup~=nil)
    if Input.click and not self._consumed and ghov then
        if type(self.groupClick)=="function" then pcall(self.groupClick,self) else self.groupPopup=self.groupPopup and nil or{x=gx,y=top+h+6*s,w=gw} end
        self.openDrop=nil
self.keyMenu=nil
self.colorPopup=nil
self.configPopup=nil
self.accountOpen=false
self:_consume()
    end

    local sx=X+(self.width-69)*s
local shov=self:_hit(sx,top,44*s,h)and not self:_hasPopup()
    if shov then self:_fill("control",sx,top,44*s,h,"activeItem",12*s) end
    self:_icon("search",sx+22*s,top+25*s,20*s,shov and"text"or"icon")
    if Input.click and not self._consumed and not self:_hasPopup() and shov then self.searchOpen=not self.searchOpen
self:_consume() end
end

function Window:_clampPopup(p)
    local s=self.scale
local left=self.x+8*s
local right=self.x+self.width*s-8*s
local top=self.y+8*s
local bottom=self.y+self.height*s-8*s
    p.x=clamp(p.x,left,max(left,right-p.w))
if p.y+(p.h or 0)>bottom then p.y=max(top,p.anchorY and(p.anchorY-(p.h or 0)-6*s)or(bottom-(p.h or 0)))end
p.y=max(top,p.y)
return p
end

function Window:_popupFrame(p)
    self:_fill("popup",p.x,p.y,p.w,p.h,"popup",10*self.scale)
    self:_out(p.x,p.y,p.w,p.h,10*self.scale,.9,self:_color("outline"),150)
end

function Window:_drawDropdownPopup()
    local p=self.openDrop
if not p then return end
local c=p.control
if not alive(c)or not visibilityPass(c)then self.openDrop=nil
return end
    if c.optionsSource then c:RefreshOptionsSource(false) end
    local s=self.scale
local F=REF.Full
local maxRows=min(c:GetMaxVisibleOptions(),max(1,#c.options))
local ph=12*s+maxRows*F.itemH*s
p.h=ph
p.w=p.w or F.ctrlW*s
p.anchorY=p.y-6*s
self:_clampPopup(p)
self:_popupFrame(p)
    local maxScroll=max(0,#c.options-maxRows)
p.scroll=clamp(p.scroll or c.dropdownScroll or 0,0,maxScroll)
c.dropdownScroll=p.scroll
    if self:_hit(p.x,p.y,p.w,p.h)and Input.wheel~=0 then p.scroll=clamp(p.scroll+Input.wheel*c:GetDropdownScrollStep(),0,maxScroll)
c.dropdownScroll=p.scroll end
    for row=1,maxRows do
        local i=row+p.scroll
if i>#c.options then break end
local yy=p.y+6*s+(row-1)*F.itemH*s
local hov=self:_hit(p.x+5*s,yy,p.w-10*s,F.itemH*s)
local selected=c.type=="dropdown"and c.value==i or(c.type=="multiselect"and c.value[i]==true)
        if hov then self:_fill("control",p.x+5*s,yy,p.w-10*s,F.itemH*s,"controlHover",F.itemR*s) elseif selected then rect(p.x+5*s,yy,p.w-10*s,F.itemH*s,self:_color("accent"),F.itemR*s,24) end
        textC(fit(c.options[i],p.w-50*s,F.itemFont*s,"Verdana"),p.x+F.itemPad*s,yy+F.itemH*s*.5,self:_color(selected and"white"or"text"),F.itemFont*s,"Verdana")
        if selected then ICON.check(p.x+p.w-21*s,yy+F.itemH*s*.5,13*s,self:_color("accent")) end
        if Input.click and not self._consumed and hov then
            if c.type=="dropdown"then c:Set(i)
self.openDrop=nil else c:ToggleOption(i) end
self:_consume()
        end
    end
    if maxScroll>0 then
        local tx=p.x+p.w-6*s
local top=p.y+8*s
local th=p.h-16*s
local thumb=max(24*s,th*(maxRows/#c.options))
local span=max(1,th-thumb)
local yy=top+span*(p.scroll/maxScroll)
rect(tx,top,2*s,th,self:_color("control"),1*s,120)
rect(tx-1*s,yy,4*s,thumb,self:_color("outline"),2*s,220)
        if Input.click and not self._consumed and self:_hit(tx-6*s,yy-3*s,14*s,thumb+6*s)then p.drag={top=top,span=span,off=Input.my-yy}
self:_consume()end
        if p.drag then if Input.left then p.scroll=clamp(round((Input.my-p.drag.top-p.drag.off)/p.drag.span*maxScroll),0,maxScroll)
c.dropdownScroll=p.scroll else p.drag=nil end end
    end
end

function Window:_drawKeyMenu()
    local p=self.keyMenu
if not p then return end
local c=p.control
if not alive(c)then self.keyMenu=nil
return end
    local s=self.scale
local C=REF.Compact
local items={{"Hold","Hold"},{"Toggle","Toggle"},{"Always","Always"},{"Clear","__clear"},{"Close","__close"}}
p.h=#items*C.itemH*s+12*s
p.w=max(p.w or 170*s,170*s)
p.anchorY=p.y-6*s
self:_clampPopup(p)
self:_popupFrame(p)
    for i,it in ipairs(items)do local y=p.y+6*s+(i-1)*C.itemH*s
local hov=self:_hit(p.x+5*s,y,p.w-10*s,C.itemH*s)
if hov then self:_fill("control",p.x+5*s,y,p.w-10*s,C.itemH*s,"controlHover",C.itemR*s)end
local sel=c.mode==it[2]
textC(it[1],p.x+12*s,y+C.itemH*s*.5,self:_color(it[2]=="__clear"and"danger"or(sel and"accent"or"text")),C.itemFont*s,"Verdana")
if sel then ICON.check(p.x+p.w-20*s,y+C.itemH*s*.5,12*s,self:_color("accent"))end
if Input.click and not self._consumed and hov then if it[2]=="__clear"then c:ClearKey()
self.keyMenu=nil elseif it[2]=="__close"then self.keyMenu=nil else c:SetMode(it[2])
self.keyMenu=nil end
self:_consume()end end
end

function Window:_drawColorPopup()
    local p=self.colorPopup
if not p then return end
local c=p.control
if not alive(c)then self.colorPopup=nil
return end
    local s=self.scale
local C=REF.Compact
p.w=300*s
p.h=(12+34+4*48+10)*s
p.anchorY=p.y-8*s
self:_clampPopup(p)
self:_popupFrame(p)
    textC("COLOR",p.x+14*s,p.y+22*s,self:_color("muted"),13*s,"Verdana")
    local labels={"Red","Green","Blue","Alpha"}
local vals={c.value[1],c.value[2],c.value[3],c.value[4]}
for i=1,4 do local cy=p.y+(50+(i-1)*48)*s
local l=p.x+14*s
local r=p.x+p.w-14*s
textC(labels[i],l,cy,self:_color("text"),15*s,"Verdana")
local trackX=p.x+86*s
local trackW=p.w-145*s
rect(trackX,cy-2*s,trackW,4*s,self:_color("control"),2*s,255)
local pp=clamp(vals[i]/255,0,1)
rect(trackX,cy-2*s,trackW*pp,4*s,self:_color("accent"),2*s,255)
circle(trackX+trackW*pp,cy,7*s,self:_color("white"),255)
local txt=tostring(vals[i])
local tw=measure(txt,14*s,"Verdana")
self:_fill("control",r-44*s,cy-14*s,44*s,28*s,"control",6*s)
textC(txt,r-22*s-tw*.5,cy,self:_color("text"),14*s,"Verdana")
if Input.left and self:_hit(trackX-5*s,cy-14*s,trackW+10*s,28*s)then local nv=clamp(round((Input.mx-trackX)/trackW*255),0,255)
local q=copy(c.value)
q[i]=nv
c:Set(q)end end
    local by=p.y+p.h-40*s
local half=(p.w-34*s)*.5
local function btn(x,label,fn)local hov=self:_hit(x,by,half,29*s)
self:_fill("control",x,by,half,29*s,hov and"controlHover"or"control",7*s)
local tw=measure(label,14*s,"Verdana")
textC(label,x+(half-tw)*.5,by+14.5*s,self:_color("text"),14*s,"Verdana")
if Input.click and not self._consumed and hov then fn()
self:_consume()end end
btn(p.x+12*s,"Copy",function()E.colorClipboard=copy(c.value)end)
btn(p.x+22*s+half,"Paste",function()c:Set(E.colorClipboard)end)
end

function Window:_drawConfigPopup()
    local p=self.configPopup
if not p then return end
local s=self.scale
local C=REF.Full
local names=self:GetNamedConfigs()
local extra=3
p.h=(12+(#names+extra)*C.itemH)*s
p.anchorY=p.y-6*s
self:_clampPopup(p)
self:_popupFrame(p)
    local rows={}
for _,n in ipairs(names)do rows[#rows+1]={n,n==self.configName and"selected"or"load"}end
rows[#rows+1]={"New Config","new"}
rows[#rows+1]={"Duplicate","duplicate"}
rows[#rows+1]={"Delete Current","delete"}
    for i,it in ipairs(rows)do local y=p.y+6*s+(i-1)*C.itemH*s
local hov=self:_hit(p.x+5*s,y,p.w-10*s,C.itemH*s)
if hov then self:_fill("control",p.x+5*s,y,p.w-10*s,C.itemH*s,"controlHover",C.itemR*s)end
local sel=it[2]=="selected"
textC(fit(it[1],p.w-45*s,C.itemFont*s,"Verdana"),p.x+12*s,y+C.itemH*s*.5,self:_color(it[2]=="delete"and"danger"or(sel and"accent"or"text")),C.itemFont*s,"Verdana")
if sel then ICON.check(p.x+p.w-20*s,y+C.itemH*s*.5,12*s,self:_color("accent"))end
if Input.click and not self._consumed and hov then if it[2]=="new"then local base="Config"
local k=1
while self.configProfiles[base.." "..k]do k=k+1 end
local n=base.." "..k
self.configProfiles[n]=self:GetConfig()
self.configName=n elseif it[2]=="duplicate"then self:DuplicateNamedConfig()elseif it[2]=="delete"then self:DeleteNamedConfig()else self:LoadNamedConfig(it[1])end
self.configPopup=nil
self:_consume()end end
end

function Window:_drawGroupPopup()
    local p=self.groupPopup
if not p then return end
local s=self.scale
local C=REF.Full
p.h=(12+#self.groups*C.itemH)*s
p.anchorY=p.y-6*s
self:_clampPopup(p)
self:_popupFrame(p)
    for i,g in ipairs(self.groups)do local y=p.y+6*s+(i-1)*C.itemH*s
local hov=self:_hit(p.x+5*s,y,p.w-10*s,C.itemH*s)
if hov then self:_fill("control",p.x+5*s,y,p.w-10*s,C.itemH*s,"controlHover",C.itemR*s)end
local sel=g==self.group
textC(fit(g,p.w-42*s,C.itemFont*s,"Verdana"),p.x+12*s,y+C.itemH*s*.5,self:_color(sel and"accent"or"text"),C.itemFont*s,"Verdana")
if sel then ICON.check(p.x+p.w-18*s,y+C.itemH*s*.5,11*s,self:_color("accent"))end
if Input.click and not self._consumed and hov then self.group=g
self.groupPopup=nil
self:_consume()end end
end

function Window:_settingsTab()
    if self.settingsPage and self.settingsPage.Tab then return self.settingsPage.Tab end
    for _,t in ipairs(self.tabs)do if lower(t.name)=="settings"or lower(t.name)=="config"or lower(t.name)=="configs"then return t end end
end
function Window:_drawAccountPopup()
    if not self.accountOpen then return end
local s=self.scale
local _,profileY=self:_sidebarGeometry()
local p={x=self.x+7*s,w=261*s,h=236*s,y=profileY-244*s}
self:_clampPopup(p)
self:_popupFrame(p)
    local titleY=p.y+24*s
textC("ACCOUNT",p.x+14*s,titleY,self:_color("muted"),13*s,"Verdana")
    local items={{"Settings","settings","settings"},{"Profile","user","profile"},{"Reset UI Position","misc","center"},{"Close","misc","close"}}
    for i,it in ipairs(items)do local y=p.y+42*s+(i-1)*36*s
local hov=self:_hit(p.x+6*s,y,p.w-12*s,34*s)
if hov then self:_fill("control",p.x+6*s,y,p.w-12*s,34*s,"controlHover",7*s)end
self:_icon(it[2],p.x+21*s,y+17*s,14*s,hov and"accent"or"icon")
textC(it[1],p.x+38*s,y+17*s,self:_color("text"),15*s,"Verdana")
if Input.click and not self._consumed and hov then if it[3]=="settings"then local t=self:_settingsTab()
if not t then local sp=Fawn:CreateSettingsPage(self,{}) t=sp.Tab end
if t then self:SelectTab(t)end
self.accountOpen=false elseif it[3]=="center"then self:Center()
self.accountOpen=false elseif it[3]=="close"then self.accountOpen=false else if type(self.profileMenuItems.profile)=="function"then pcall(self.profileMenuItems.profile,self)end
self.accountOpen=false end
self:_consume()end end
end

function Window:_drawSearchPopup()
    if not self.searchOpen then return end
local s=self.scale
local w=310*s
local h=44*s
local x=self.x+(self.width-REF.RightMargin)*s-w
local y=self.y+78*s
local p={x=x,y=y,w=w,h=h}
self:_clampPopup(p)
self:_popupFrame(p)
self:_icon("search",x+20*s,y+22*s,15*s,"icon")
local shown=self.search~=""and self.search or"Search controls..."
textC(fit(shown,w-52*s,15*s,"Verdana"),x+40*s,y+22*s,self:_color(self.search~=""and"text"or"muted"),15*s,"Verdana")
    -- lightweight filtering: selecting the first tab whose control label contains the query
    if self.search~="" then local q=lower(self.search)
for _,t in ipairs(self.tabs)do for _,sec in ipairs(t.sections)do for _,c in ipairs(sec.controls)do if alive(c)and lower(c.label):find(q,1,true)then if self.activeTab==t then return end end end end end end
end

function Window:_updateWindowDragResize()
    local s=self.scale
local X,Y=self.x,self.y
local W,H=self.width*s,self.height*s
local edge=max(6,7*s)
    if self.resizing then
        if self.resizable==false then self.resizing=nil
return end
        if not Input.left then self.resizing=nil
return end
        local r=self.resizing
local dx=(Input.mx-r.mx)/s
local dy=(Input.my-r.my)/s
local nx,ny,nw,nh=r.x,r.y,r.w,r.h
        if r.l then nx=r.x+dx*s
nw=r.w-dx end
if r.r then nw=r.w+dx end
if r.t then ny=r.y+dy*s
nh=r.h-dy end
if r.b then nh=r.h+dy end
        nw=clamp(nw,self.minWidth,self.maxWidth)
nh=clamp(nh,self.minHeight,self.maxHeight)
if r.l then nx=r.x+(r.w-nw)*s end
if r.t then ny=r.y+(r.h-nh)*s end
self.x,self.y,self.width,self.height=nx,ny,nw,nh
return
    end
    if self.dragging then
        if self.draggable==false then self.dragging=nil
return end
        if Input.left then self.x=Input.mx-self.dragging.ox
self.y=Input.my-self.dragging.oy else self.dragging=nil end
        return
    end
    if not Input.click or self._consumed or self:_hasPopup() then return end
    local l=self:_hit(X-edge,Y,edge*2,H)
local r=self:_hit(X+W-edge,Y,edge*2,H)
local t=self:_hit(X,Y-edge,W,edge*2)
local b=self:_hit(X,Y+H-edge,W,edge*2)
    if self.resizable~=false and (l or r or t or b) then self.resizing={mx=Input.mx,my=Input.my,x=X,y=Y,w=self.width,h=self.height,l=l,r=r,t=t,b=b}
self:_consume()
return end
    local headerHit=(self.kind=="Panel"or self.tabBarVisible==false)and self:_hit(X,Y,W,64*s)or self:_hit(X,Y,REF.Sidebar*s,90*s)
    if self.draggable~=false and headerHit then self.dragging={ox=Input.mx-X,oy=Input.my-Y}
self:_closePopups()
self:_consume()end
end

function Window:_processKeybinds()
    self:ForEachControl(function(c)
        local list={}
if c.type=="keybind"then list[1]=c end
if c.keybind then list[#list+1]=c.keybind end
        for _,k in ipairs(list)do if alive(k)then local down=k.key and nativeKey(k.key)or false
if k.mode=="Always"then k.active=true elseif k.mode=="Hold"then k.active=down elseif k.mode=="Toggle"then if down and not k.last then k.active=not k.active end end
k.last=down end end
    end)
end

function Window:_processBindCapture()
    local c=self.captureBind
if not c then return end
    if E.paintCount<=(self._captureFrame or 0)then return end
    for _,k in ipairs(POLL)do if Input.pressed[k]then if k=="Escape"or k=="Backspace"then c:ClearKey()else c:SetKey(k,k)end
self.captureBind=nil
return end end
end

function Window:_toggleByKey()
    if self.toggleControl and self.toggleControl.type=="keybind"then if Input.pressed[self.toggleControl.key]then self:Toggle()end
return end
    local k=self.toggleKey
if k and Input.pressed[tostring(k)]then self:Toggle()end
end

function Window:_drawPanelHeader()
    local s=self.scale
local X,Y=self.x,self.y
local W=self.width*s
    self:_fill("sidebar",X,Y,W,64*s,"card",self.corner*s)
line(X,Y+64*s,X+W,Y+64*s,self:_color("line"),1,36)
    textC(self.brand,X+18*s,Y+25*s,self:_color("text"),18*s,"Verdana")
if self.subtitle~=""then textC(self.subtitle,X+18*s,Y+45*s,self:_color("muted"),12*s,"Verdana")end
    local tw=measure(self.toggleLabel or"",12*s,"Verdana")
textC(self.toggleLabel or"",X+W-18*s-tw,Y+32*s,self:_color("muted"),12*s,"Verdana")
end

function Window:_render()
    if self.destroyed then return end
    self:_toggleByKey()
self:_processKeybinds()
self:_processBindCapture()
self:_processInputEdit()
self:_processSliderEdit()
    if not self.visible then return end
    self._consumed=false
    self:_updateWindowDragResize()
    local s=self.scale
local X,Y=self.x,self.y
local W,H=self.width*s,self.height*s
    -- popup outside click closes only the top modal without triggering the underlying control
    if Input.click and not self._consumed and self:_hasPopup()then
        local inside=false
        local ps={self.openDrop,self.keyMenu,self.colorPopup,self.configPopup,self.groupPopup}
        for _,p in ipairs(ps)do if p and p.x and p.y and p.w and p.h and self:_hit(p.x,p.y,p.w,p.h)then inside=true break end end
        if self.accountOpen then local _,py=self:_sidebarGeometry()
if self:_hit(X+7*s,py-244*s,261*s,236*s)or self:_hit(X+15*s,py,245*s,55*s)then inside=true end end
        if not inside then self:_closePopups()
self:_consume()end
    end
    self:_fill("main",X,Y,W,H,"menuBg",self.corner*s)
    -- content is drawn before chrome; chrome masks overflow.
    self:_drawContent()
    if self.kind=="Panel"or self.tabBarVisible==false then self:_drawPanelHeader() else self:_drawSidebar()
self:_drawTopbar() end
    self:_out(X,Y,W,H,self.corner*s,self.borderThickness,self.outlineColor,255)
    self:_drawDropdownPopup()
self:_drawKeyMenu()
self:_drawColorPopup()
self:_drawConfigPopup()
self:_drawGroupPopup()
self:_drawAccountPopup()
self:_drawSearchPopup()
end

-- Unified overlays
local function overlayTheme(o)
    if o.independentTheme and o.themeName and PRESETS[o.themeName]then return PRESETS[o.themeName] end
    return(o.window and o.window.theme)or PRESETS["Modern Blue"]
end
local function overlayScale(o)return(o.window and o.window.scale)or(o.scale or 1)end
function Overlay:SetVisible(v)self.visible=v~=false
return self end
function Overlay:Toggle()self.visible=not self.visible
return self end
function Overlay:SetPosition(x,y)self.x=tonumber(x)or self.x
self.y=tonumber(y)or self.y
return self end
function Overlay:GetPosition()return self.x,self.y end
function Overlay:SetDraggable(v)self.draggable=v~=false
return self end
function Overlay:SetTheme(name)if PRESETS[name]then self.themeName=name
self.independentTheme=true end
return self end
function Overlay:BindWindow(w)if kind(w)=="Window"or kind(w)=="Panel"then self.window=w end
return self end
function Overlay:Destroy()if self.destroyed then return end
self.destroyed=true
removeValue(E.overlays,self)end
function Overlay:SetLayer(v)self.layer=(v=="back"or v=="behind")and"back"or"front"
return self end
function Overlay:SetIndependentTheme(v)self.independentTheme=v~=false
return self end
function Overlay:SetPadding(v)self.padding=max(0,tonumber(v)or self.padding or 14)
return self end
function Overlay:GetPadding()return self.padding or 14 end
function Overlay:SetAutoSize(v)self.autoSize=v~=false
return self end
function Overlay:GetAutoSize()return self.autoSize~=false end
function Overlay:SetMinWidth(v)self.minWidth=max(40,tonumber(v)or self.minWidth or 120)
return self end
function Overlay:SetMaxWidth(v)self.maxWidth=max(self.minWidth or 120,tonumber(v)or self.maxWidth or 800)
return self end
function Overlay:GetSize()return self.width or 0,self.height or 0 end
function Overlay:_theme(key)local t=overlayTheme(self)
return t[key]or MODERN[key]end
function Overlay:_frame(x,y,w,h,header)
    local s=overlayScale(self)
local win=self.window
    local c=glassColor(win,"overlay",self:_theme("popup"))
rect(x,y,w,h,c,10*s,alphaFor(win,"overlay",c[4]or 255))
outline(x,y,w,h,(win and win.outlineColor)or self:_theme("outline"),10*s,170,max(.8,s*((win and win.outlineStrength)or 1)))
    if header then line(x,y+header,x+w,y+header,self:_theme("line"),1,32)end
end
function Overlay:_drag(x,y,w,h,headerH)
    if self.draggable==false then return end
    if self._drag then if Input.left then self.x=Input.mx-self._drag.ox
self.y=Input.my-self._drag.oy else self._drag=nil end
return end
    if Input.click and self:_hitOverlay(x,y,w,headerH or h)then self._drag={ox=Input.mx-x,oy=Input.my-y}end
end
function Overlay:_hitOverlay(x,y,w,h)return Input.mx>=x and Input.mx<x+w and Input.my>=y and Input.my<y+h end

setmetatable(Watermark,{__index=Overlay})
setmetatable(KeybindList,{__index=Overlay})
setmetatable(InfoPanel,{__index=Overlay})
setmetatable(ESPPreview,{__index=Overlay})

local function newOverlay(cls,window,opt,kindName)
    opt=type(opt)=="table"and opt or{}
local o=setmetatable({kind=kindName,id=newId(lower(kindName)),window=window,x=tonumber(opt.x)or 25,y=tonumber(opt.y)or 25,width=tonumber(opt.width)or 240,height=tonumber(opt.height)or 80,visible=opt.visible~=false,draggable=opt.draggable~=false,layer=opt.layer=="back"and"back"or"front",padding=tonumber(opt.padding)or 14,autoSize=opt.autoSize~=false,minWidth=tonumber(opt.minWidth)or 120,maxWidth=tonumber(opt.maxWidth)or 700,independentTheme=opt.independentTheme==true,themeName=opt.theme,title=tostring(opt.title or kindName),destroyed=false},cls)
E.overlays[#E.overlays+1]=o
return o
end

function Watermark:SetSegments(list)self.segments={}
for _,v in ipairs(list or{})do self:AddSegment(v)end
return self end
function Watermark:AddSegment(value,opt)local q=type(value)=="table"and copy(value)or{value=value}
if type(opt)=="table"then for k,v in pairs(opt)do q[k]=v end end
self.segments[#self.segments+1]=q
return self end
function Watermark:Clear()self.segments={}
return self end
function Watermark:SetText(i,v)local q=self.segments[i]
if q then q.text=v
q.value=v end
return self end
function Watermark:SetSegmentPadding(v)self.segmentPadding=max(2,tonumber(v)or 10)
return self end
function Watermark:SetAutoWidth(v)self.autoWidth=v~=false
return self end
function Watermark:InsertSegment(index,value,opt)local q=type(value)=="table"and copy(value)or{value=value}
if type(opt)=="table"then for k,v in pairs(opt)do q[k]=v end end
insert(self.segments,clamp(floor(tonumber(index)or 1),1,#self.segments+1),q)
return self end
function Watermark:GetSegment(i)return self.segments[i]end
function Watermark:GetSegments()return copy(self.segments)end
function Watermark:GetSegmentCount()return#self.segments end
function Watermark:SetSegment(i,value,opt)if self.segments[i]then local q=type(value)=="table"and copy(value)or{value=value}
if type(opt)=="table"then for k,v in pairs(opt)do q[k]=v end end
self.segments[i]=q end
return self end
function Watermark:RemoveSegment(i)if type(i)=="number"then remove(self.segments,i)end
return self end
function Watermark:MoveSegment(from,to)local q=remove(self.segments,from)
if q then insert(self.segments,clamp(to,1,#self.segments+1),q)end
return self end
function Watermark:ClearSegments()return self:Clear()end
function Watermark:SetSegmentsSource(fn,opt)self.segmentSource=fn
self.segmentSourceOpt=type(opt)=="table"and opt or{}
self._segmentNext=0
return self end
function Watermark:ClearSegmentsSource()self.segmentSource=nil
return self end
function Watermark:RefreshSegmentsSource(force)if type(self.segmentSource)~="function"then return self end
local n=nowMs()
local interval=tonumber(self.segmentSourceOpt and self.segmentSourceOpt.interval)or 250
if not force and n<(self._segmentNext or 0)then return self end
self._segmentNext=n+interval
local ok,q=pcall(self.segmentSource,self)
if ok and type(q)=="table"then self:SetSegments(q)end
return self end
function Watermark:_render()
    if not self.visible or self.destroyed then return end
self:RefreshSegmentsSource(false)
local s=overlayScale(self)
local pad=(self.padding or 14)*s
local segPad=(self.segmentPadding or 10)*s
local font=14*s
local h=36*s
local parts={}
local total=pad*2
    for _,seg in ipairs(self.segments)do local v=seg.brand and(Fawn.ProductName)or resolve(seg.text~=nil and seg.text or seg.value,self,seg)
v=tostring(v or"")
parts[#parts+1]={v=v,accent=seg.accent==true or seg.brand==true}
local reserve=seg.reserve and tostring(resolve(seg.reserve,self,seg))or v
local tw=measure(reserve,font,"Verdana")
parts[#parts].w=tw
total=total+tw+segPad*2 end
    if #parts==0 then parts={{v=Fawn.ProductName,w=measure(Fawn.ProductName,font,"Verdana"),accent=true}}
total=pad*2+parts[1].w+segPad*2 end
    if self.autoWidth~=false then self.width=clamp(total/s,self.minWidth or 120,self.maxWidth or 700)end
self.height=h/s
local w=self.width*s
self:_frame(self.x,self.y,w,h,nil)
local x=self.x+pad
for i,p in ipairs(parts)do if i>1 then line(x-segPad*.3,self.y+8*s,x-segPad*.3,self.y+h-8*s,self:_theme("line"),1,38)end
textC(p.v,x+segPad,self.y+h*.5,p.accent and self:_theme("accent")or self:_theme("text"),font,"Verdana")
x=x+p.w+segPad*2 end
self:_drag(self.x,self.y,w,h,h)
end

function KeybindList:Track(control,name)if control then self.tracked[control]=name or control.label or"Keybind" end
return self end
function KeybindList:Untrack(control)self.tracked[control]=nil
return self end
function KeybindList:Clear()self.tracked={}
return self end
function KeybindList:SetOnlyActive(v)self.onlyActive=v~=false
return self end
function KeybindList:_entries()
    local out={}
for c,name in pairs(self.tracked)do if alive(c)then local k=c.type=="keybind"and c or c.keybind
if k and(k.keybindList~=false)then if not self.onlyActive or k.active then out[#out+1]={name=name,key=k}end end end end
    if self.auto and self.window then self.window:ForEachControl(function(c)local k=c.type=="keybind"and c or c.keybind
if k and k.keybindList~=false and(not self.onlyActive or k.active)and not self.tracked[c]then out[#out+1]={name=c.label,key=k}end end)end
    sort(out,function(a,b)return a.name<b.name end)
return out
end
function KeybindList:_render()
    if not self.visible or self.destroyed then return end
local s=overlayScale(self)
local entries=self:_entries()
local row=28*s
local head=38*s
local pad=12*s
local w=max((self.minWidth or 200)*s,self.width*s)
if self.autoSize~=false then local widest=0
for _,e in ipairs(entries)do widest=max(widest,measure(e.name,14*s,"Verdana")+measure(e.key.keyLabel or"None",13*s,"Verdana")+70*s)end
w=clamp(max(widest,210*s),(self.minWidth or 160)*s,(self.maxWidth or 520)*s)
self.width=w/s end
local h=head+max(row,#entries*row)+8*s
self.height=h/s
self:_frame(self.x,self.y,w,h,head)
textC(upper(self.title or"KEYBINDS"),self.x+pad,self.y+head*.5,self:_theme("text"),14*s,"Verdana")
for i,e in ipairs(entries)do local y=self.y+head+(i-1)*row
local active=e.key.active
textC(fit(e.name,w-100*s,14*s,"Verdana"),self.x+pad,y+row*.5,active and self:_theme("text")or self:_theme("muted"),14*s,"Verdana")
local val=e.key.mode=="Always"and"Always"or(e.key.keyLabel or(e.key.key and tostring(e.key.key):upper()or"None"))
local tw=measure(val,13*s,"Verdana")
textC(val,self.x+w-pad-tw,y+row*.5,active and self:_theme("accent")or self:_theme("muted"),13*s,"Verdana")end
if #entries==0 then textC("No active binds",self.x+pad,self.y+head+row*.5,self:_theme("muted"),13*s,"Verdana")end
self:_drag(self.x,self.y,w,h,head)
end

function InfoPanel:AddRow(label,value,opt)local r={label=tostring(label or""),value=value,opt=type(opt)=="table"and opt or{}}
self.rows[#self.rows+1]=r
return r end
function InfoPanel:SetRow(i,label,value)local r=type(i)=="number"and self.rows[i]or self:FindRow(i)
if r then if label~=nil then r.label=tostring(label)end
if value~=nil then r.value=value end end
return self end
function InfoPanel:Clear()self.rows={}
return self end
function InfoPanel:InsertRow(index,label,value,opt)local r={label=tostring(label or""),value=value,opt=type(opt)=="table"and opt or{}}
insert(self.rows,clamp(floor(tonumber(index)or 1),1,#self.rows+1),r)
return r end
function InfoPanel:GetRow(i)return type(i)=="number"and self.rows[i]or self:FindRow(i)end
function InfoPanel:GetRows()return self.rows end
function InfoPanel:GetRowCount()return#self.rows end
function InfoPanel:FindRow(label)for _,r in ipairs(self.rows)do if r.label==label then return r end end end
function InfoPanel:RemoveRow(which)local r=self:GetRow(which)
if r then removeValue(self.rows,r)end
return self end
function InfoPanel:MoveRow(from,to)local r=type(from)=="number"and remove(self.rows,from)or self:GetRow(from)
if r then removeValue(self.rows,r)
insert(self.rows,clamp(floor(tonumber(to)or 1),1,#self.rows+1),r)end
return self end
function InfoPanel:SetRows(rows)self.rows={}
for _,r in ipairs(rows or{})do self:AddRow(r.label or r[1],r.value or r[2],r.opt)end
return self end
function InfoPanel:SetRowsSource(fn,opt)self.rowsSource=fn
self.rowsSourceOpt=type(opt)=="table"and opt or{}
self._rowsNext=0
return self end
function InfoPanel:ClearRowsSource()self.rowsSource=nil
return self end
function InfoPanel:RefreshRowsSource(force)if type(self.rowsSource)~="function"then return self end
local n=nowMs()
local interval=tonumber(self.rowsSourceOpt and self.rowsSourceOpt.interval)or 250
if not force and n<(self._rowsNext or 0)then return self end
self._rowsNext=n+interval
local ok,q=pcall(self.rowsSource,self)
if ok and type(q)=="table"then self:SetRows(q)end
return self end
function InfoPanel:_render()
    if not self.visible or self.destroyed then return end
self:RefreshRowsSource(false)
local s=overlayScale(self)
local head=38*s
local row=29*s
local pad=12*s
local w=max((self.minWidth or 220)*s,self.width*s)
if self.autoSize~=false then local widest=0
for _,r in ipairs(self.rows)do local v=tostring(resolve(r.value,self,r)or"")
widest=max(widest,measure(r.label,14*s,"Verdana")+measure(v,14*s,"Verdana")+60*s)end
w=clamp(max(widest,220*s),(self.minWidth or 160)*s,(self.maxWidth or 600)*s)
self.width=w/s end
local h=head+max(row,#self.rows*row)+8*s
self.height=h/s
self:_frame(self.x,self.y,w,h,head)
textC(upper(self.title or"INFO"),self.x+pad,self.y+head*.5,self:_theme("text"),14*s,"Verdana")
for i,r in ipairs(self.rows)do local y=self.y+head+(i-1)*row
local v=tostring(resolve(r.value,self,r)or"")
textC(fit(r.label,w*.55,14*s,"Verdana"),self.x+pad,y+row*.5,self:_theme("muted"),14*s,"Verdana")
local tw=measure(fit(v,w*.4,14*s,"Verdana"),14*s,"Verdana")
textC(fit(v,w*.4,14*s,"Verdana"),self.x+w-pad-tw,y+row*.5,r.opt.accent and self:_theme("accent")or self:_theme("text"),14*s,"Verdana")end
if #self.rows==0 then textC("No data",self.x+pad,self.y+head+row*.5,self:_theme("muted"),13*s,"Verdana")end
self:_drag(self.x,self.y,w,h,head)
end

-- ESP preview/editor
local ESP_FEATURE_ALIASES={box="boxes",boxes="boxes",name="name",names="name",health="healthbar",healthbar="healthbar",healthtext="healthtext",distance="distance",skeleton="skeleton",snapline="snapline"}
local function espFeature(n)return ESP_FEATURE_ALIASES[lower(tostring(n or""))]or lower(tostring(n or""))end
function ESPPreview:SetFeature(name,v)self.features[espFeature(name)]=v~=false
return self end
function ESPPreview:GetFeature(name)return self.features[espFeature(name)]==true end
function ESPPreview:SetColor(name,v)self.colors[lower(tostring(name or""))]=rgba(v,self.colors[name]or{255,255,255,255})
return self end
function ESPPreview:GetColor(name)return copy(self.colors[lower(tostring(name or""))])end
function ESPPreview:SetElementPosition(name,slot)self.positions[lower(tostring(name or""))]=tostring(slot or"top")
return self end
function ESPPreview:GetElementPosition(name)return self.positions[lower(tostring(name or""))]end
function ESPPreview:SetEditable(v)self.editable=v~=false
return self end
function ESPPreview:SetHealth(v)self.health=clamp(tonumber(v)or self.health,0,100)
self.healthFixed=true
return self end
function ESPPreview:SetAnimateHealth(v)self.animateHealth=v~=false
if self.animateHealth then self.healthFixed=false end
return self end
function ESPPreview:GetAnimateHealth()return self.animateHealth~=false and not self.healthFixed end
function ESPPreview:SetText(name,value)self.texts[lower(tostring(name or""))]=tostring(value or"")
return self end
function ESPPreview:BindFeature(name,control)self.featureBindings[espFeature(name)]=control
return self end
function ESPPreview:BindColor(name,control)self.colorBindings[lower(tostring(name or""))]=control
return self end
function ESPPreview:UnbindFeature(name)self.featureBindings[espFeature(name)]=nil
return self end
function ESPPreview:UnbindColor(name)self.colorBindings[lower(tostring(name or""))]=nil
return self end
function ESPPreview:SetHealthStyle(v)local q=lower(tostring(v or"bar"))
self.healthStyle=(q=="text"or q=="both")and q or"bar"
return self end
function ESPPreview:SetBoxThickness(v)self.boxThickness=clamp(tonumber(v)or 1,1,5)
return self end
function ESPPreview:SetDocked(v)
    self.docked=v~=false
    if self.tab and self.docked then self.tab.dockedPreview=self elseif self.tab and self.tab.dockedPreview==self then self.tab.dockedPreview=nil end
    return self
end
function ESPPreview:ResetLayout()self.positions={name="top",distance="bottom",healthtext="left"}
self.offsets={}
return self end
function ESPPreview:SetDockWidthRatio(v)self.dockWidthRatio=clamp(tonumber(v)or .36,.25,.55)
return self end
function ESPPreview:SetDockGap(v)self.dockGap=max(4,tonumber(v)or REF.ColumnGap)
return self end
function ESPPreview:GetDockedSize()if not self.window then return 0,0 end
local x,y,w,h=self.window:GetBodyBounds()
return w*(self.dockWidthRatio or .36),h end
function ESPPreview:_syncBindings()
    for name,c in pairs(self.featureBindings)do if alive(c)then local v=c:Get()
self.features[name]=v==true end end
    for name,c in pairs(self.colorBindings)do if alive(c)then local v=c:Get()
if type(v)=="table"then self.colors[name]=rgba(v,self.colors[name])end end end
end
function ESPPreview:_currentHealth()
    if self.healthFixed or self.animateHealth==false then return self.health end
    local t=nowMs()/1000
return clamp(64+29*sin(t*.9)+7*sin(t*2.1),5,100)
end
function ESPPreview:_theme(key)return(self.window and self.window.theme[key])or MODERN[key]end
function ESPPreview:_drawBody(x,y,w,h,docked)
    self:_syncBindings()
local win=self.window
local s=win and win.scale or 1
local head=42*s
local pad=15*s
    local frame=glassColor(win,"card",self:_theme("card"))
rect(x,y,w,h,frame,14*s,alphaFor(win,"card",frame[4]or 255))
outline(x,y,w,h,(win and win.outlineColor)or self:_theme("outline"),14*s,130,max(.8,s*((win and win.outlineStrength)or 1)))
    textC(upper(self.title or"ESP PREVIEW"),x+pad,y+head*.5,self:_theme("muted"),13*s,"Verdana")
line(x,y+head,x+w,y+head,self:_theme("line"),1,32)
    local stageX=x+pad
local stageY=y+head+pad
local stageW=w-pad*2
local stageH=h-head-pad*2
    local stage=glassColor(win,"control",self:_theme("control"))
rect(stageX,stageY,stageW,stageH,stage,12*s,alphaFor(win,"control",stage[4]or 255))
outline(stageX,stageY,stageW,stageH,self:_theme("outline"),12*s,80,1*s)
    local humanW=min(stageW*.52,180*s)
local humanH=min(stageH*.66,330*s)
local bx=stageX+(stageW-humanW)*.5
local by=stageY+(stageH-humanH)*.48
local boxCol=self.colors.box or self:_theme("white")
    if self.features.boxes~=false then outline(bx,by,humanW,humanH,boxCol,0,boxCol[4]or 255,(self.boxThickness or 1)*s)end
    if self.features.skeleton then local sk=self.colors.skeleton or self:_theme("white")
local cx=bx+humanW*.5
local headY=by+humanH*.15
circle(cx,headY,humanW*.08,sk,255)
line(cx,headY+humanW*.08,cx,by+humanH*.55,sk,1*s)
line(cx,by+humanH*.3,bx+humanW*.22,by+humanH*.48,sk,1*s)
line(cx,by+humanH*.3,bx+humanW*.78,by+humanH*.48,sk,1*s)
line(cx,by+humanH*.55,bx+humanW*.3,by+humanH*.9,sk,1*s)
line(cx,by+humanH*.55,bx+humanW*.7,by+humanH*.9,sk,1*s)end
    local health=self:_currentHealth()
local hpCol=self.colors.health or{92,213,117,255}
    if self.features.healthbar~=false and(self.healthStyle=="bar"or self.healthStyle=="both"or self.healthStyle==nil)then local hw=5*s
local hx=bx-11*s
rect(hx,by,hw,humanH,{12,13,17,255},2*s,220)
local fillH=humanH*health/100
rect(hx,by+humanH-fillH,hw,fillH,hpCol,2*s,hpCol[4]or 255)end
    local function slotPoint(name,textW)
        local slot=self.positions[name]or(name=="distance"and"bottom"or(name=="healthtext"and"left"or"top"))
local cx=bx+humanW*.5
local cy=by+humanH*.5
        if slot=="left"then return bx-10*s-(textW or 0),cy elseif slot=="right"then return bx+humanW+10*s,cy elseif slot=="bottom"then return cx-(textW or 0)*.5,by+humanH+9*s end
        return cx-(textW or 0)*.5,by-23*s
    end
    local targets={}
    if self.features.name~=false then local q=self.texts.name or"Player"
local tw=measure(q,14*s,"Verdana")
local tx,ty=slotPoint("name",tw)
text(q,tx,ty,self.colors.name or self:_theme("text"),14*s,"Verdana")
targets.name={tx+tw*.5,ty+7*s}end
    if self.features.distance then local q=self.texts.distance or"42m"
local tw=measure(q,13*s,"Verdana")
local tx,ty=slotPoint("distance",tw)
text(q,tx,ty,self.colors.distance or self:_theme("muted"),13*s,"Verdana")
targets.distance={tx+tw*.5,ty+7*s}end
    if self.features.healthtext or self.healthStyle=="text"or self.healthStyle=="both"then local q=tostring(round(health))
local tw=measure(q,12*s,"Verdana")
local tx,ty=slotPoint("healthtext",tw)
if(self.positions.healthtext or"left")=="left"then ty=by+humanH*(1-health/100)-7*s end
text(q,tx,ty,hpCol,12*s,"Verdana")
targets.healthtext={tx+tw*.5,ty+6*s}end
    if self.features.snapline then line(stageX+stageW*.5,stageY+stageH,bx+humanW*.5,by+humanH,self.colors.snapline or self:_theme("accent"),1*s,200)end
    if self.editable then
        textC("Drag labels to reposition",stageX+10*s,stageY+stageH-15*s,self:_theme("muted"),11*s,"Verdana")
        if Input.click and not self._dragElement then for n,p in pairs(targets)do if self:_hitESP(Input.mx,Input.my,p[1]-45*s,p[2]-14*s,90*s,28*s)then self._dragElement=n
break end end end
        if self._dragElement then if Input.left then local n=self._dragElement
local relX=(Input.mx-(bx+humanW*.5))
local relY=(Input.my-(by+humanH*.5))
if abs(relX)>abs(relY)then self.positions[n]=relX<0 and"left"or"right"else self.positions[n]=relY<0 and"top"or"bottom"end else self._dragElement=nil end end
    end
end
function ESPPreview:_hitESP(mx,my,x,y,w,h)return mx>=x and mx<x+w and my>=y and my<y+h end
function ESPPreview:_renderDocked(g)if not self.visible or self.destroyed then return end
self:_drawBody(g.x,g.y,g.w,g.h,true)end
function ESPPreview:_render()
    if self.docked or not self.visible or self.destroyed then return end
local s=overlayScale(self)
local w=self.width*s
local h=self.height*s
self:_drawBody(self.x,self.y,w,h,false)
if self.draggable~=false then if self._drag then if Input.left then self.x=Input.mx-self._drag.ox
self.y=Input.my-self._drag.oy else self._drag=nil end elseif Input.click and self:_hitESP(Input.mx,Input.my,self.x,self.y,w,42*s)then self._drag={ox=Input.mx-self.x,oy=Input.my-self.y}end end
end

-- Notifications
function Notification:Dismiss()self.dismissed=true
return self end
function Notification:SetText(v)self.text=tostring(v or"")
return self end
function Notification:SetTitle(v)self.title=tostring(v or"")
return self end
function Notification:SetDuration(v)self.duration=max(.2,tonumber(v)or self.duration)
self.expires=nowMs()+self.duration*1000
return self end
function Notification:SetPosition(v)self.position=tostring(v or self.position)
return self end
function Notification:SetWidth(v)self.width=max(180,tonumber(v)or self.width)
return self end
function Notification:SetMaxLines(v)self.maxLines=max(1,floor(tonumber(v)or self.maxLines))
return self end
function Notification:SetWrap(v)self.wrap=v~=false
return self end
local function notificationAnchor(position,w,h,index,gap)
    local sw,sh=screenSize()
gap=gap or 10
local margin=18
local x,y
    if position=="Top Left"then x=margin
y=margin+(index-1)*(h+gap)
    elseif position=="Bottom Left"then x=margin
y=sh-margin-h-(index-1)*(h+gap)
    elseif position=="Top Right"then x=sw-margin-w
y=margin+(index-1)*(h+gap)
    else x=sw-margin-w
y=sh-margin-h-(index-1)*(h+gap)end
return x,y
end
function Notification:_render(index)
    if self.dismissed or self.destroyed then return false end
local now=nowMs()
if now>=self.expires then self.dismissed=true
return false end
    local win=self.window
local s=win and win.scale or 1
local w=self.width*s
local pad=14*s
local titleH=self.title~=""and 21*s or 0
local lines=self.wrap~=false and wrapText(self.text,w-pad*2,14*s,"Verdana",self.maxLines)or{fit(self.text,w-pad*2,14*s,"Verdana")}
local lh=18*s
local h=pad*2+titleH+#lines*lh
local x,y=notificationAnchor(self.position,w,h,index,8*s)
local t=win and win.theme or MODERN
local bg=glassColor(win,"overlay",t.popup)
rect(x,y,w,h,bg,10*s,alphaFor(win,"overlay",bg[4]or 255))
outline(x,y,w,h,(win and win.outlineColor)or t.outline,10*s,160,max(.8,s*((win and win.outlineStrength)or 1)))
rect(x,y,3*s,h,t.accent,2*s,255)
local yy=y+pad
if self.title~=""then text(self.title,x+pad,yy,t.text,14*s,"Verdana")
yy=yy+titleH end
for i,l in ipairs(lines)do text(l,x+pad,yy+(i-1)*lh,t.navText,14*s,"Verdana")end
return true
end

function Fawn:Notify(textValue,opt)
    opt=type(opt)=="table"and opt or{}
local n=setmetatable({kind="Notification",id=newId("notification"),window=opt.window,text=tostring(textValue or""),title=tostring(opt.title or""),duration=max(.2,tonumber(opt.duration)or 3),position=tostring(opt.position or E.notificationPosition),width=max(180,tonumber(opt.width)or 330),maxLines=max(1,floor(tonumber(opt.maxLines)or 5)),wrap=opt.wrap~=false,created=nowMs(),dismissed=false},Notification)
n.expires=n.created+n.duration*1000
E.notifications[#E.notifications+1]=n
return n
end
function Window:Notify(textValue,opt)opt=copy(type(opt)=="table"and opt or{})
opt.window=self
opt.position=opt.position or self.notificationPosition
return Fawn:Notify(textValue,opt)end
function Window:SetNotificationPosition(v)self.notificationPosition=tostring(v or"Bottom Right")
return self end
function Window:GetNotificationPosition()return self.notificationPosition end
function Fawn:SetNotificationPosition(v)E.notificationPosition=tostring(v or"Bottom Right")
return self end
function Fawn:GetNotificationPosition()return E.notificationPosition end

-- Overlay factories
function Window:Watermark(opt)local o=newOverlay(Watermark,self,opt,"Watermark")
o.segments={}
o.segmentPadding=tonumber(opt and opt.segmentPadding)or 8
o.autoWidth=not(opt and opt.autoWidth==false)
if opt and opt.segments then o:SetSegments(opt.segments)else o:AddSegment({brand=true})end
return o end
function Window:KeybindList(opt)local o=newOverlay(KeybindList,self,opt,"KeybindList")
o.tracked={}
o.onlyActive=not(opt and opt.onlyActive==false)
o.auto=not(opt and opt.auto==false)
o.minWidth=tonumber(opt and opt.minWidth)or 210
return o end
function Window:InfoPanel(opt)local o=newOverlay(InfoPanel,self,opt,"InfoPanel")
o.rows={}
o.minWidth=tonumber(opt and opt.minWidth)or 220
if opt and opt.rows then o:SetRows(opt.rows)end
return o end
function Window:ESPPreview(opt)
    opt=type(opt)=="table"and opt or{}
local o=newOverlay(ESPPreview,self,opt,"ESPPreview")
o.features={boxes=opt.boxes~=false,name=opt.name~=false,healthbar=opt.healthbar~=false,healthtext=opt.healthtext==true,distance=opt.distance==true,skeleton=opt.skeleton==true,snapline=opt.snapline==true}
o.colors={box=rgba(opt.boxColor or{235,235,238,255}),name=rgba(opt.nameColor or{235,235,238,255}),health=rgba(opt.healthColor or{92,213,117,255}),distance=rgba(opt.distanceColor or{175,178,188,255}),skeleton=rgba(opt.skeletonColor or{235,235,238,255}),snapline=rgba(opt.snaplineColor or self.theme.accent)}
o.positions={name="top",distance="bottom",healthtext="left"}
o.texts={name=tostring(opt.nameText or"Player"),distance=tostring(opt.distanceText or"42m")}
o.featureBindings={}
o.colorBindings={}
o.health=clamp(tonumber(opt.health)or 78,0,100)
o.healthFixed=opt.health~=nil
o.animateHealth=opt.animateHealth~=false
o.healthStyle=opt.healthStyle or"bar"
o.boxThickness=clamp(tonumber(opt.boxThickness)or 1,1,5)
o.editable=opt.editable~=false
o.docked=opt.docked~=false
o.dockWidthRatio=clamp(tonumber(opt.dockWidthRatio)or .36,.25,.55)
o.dockGap=max(4,tonumber(opt.dockGap)or REF.ColumnGap)
o.width=tonumber(opt.width)or 370
o.height=tonumber(opt.height)or 520
local tab=opt.tab
if kind(tab)~="Tab"and type(tab)=="string"then tab=self:GetTab(tab)end
o.tab=kind(tab)=="Tab"and tab or self:_activeTab()
if o.docked and o.tab then o.tab.dockedPreview=o end
return o
end
Window.ESPWindow=Window.ESPPreview
function Window:StatusBar(opt)return self:Watermark(opt)end
function Fawn:CreateWatermark(opt)local w=opt and opt.window
return kind(w)=="Window"and w:Watermark(opt)or newOverlay(Watermark,nil,opt,"Watermark"):SetSegments((opt and opt.segments)or{{brand=true}})end
function Fawn:CreateKeybindList(opt)local w=opt and opt.window
local o=kind(w)=="Window"and w:KeybindList(opt)or newOverlay(KeybindList,nil,opt,"KeybindList")
o.tracked=o.tracked or{}
o.onlyActive=true
return o end
function Fawn:CreateInfoPanel(opt)local w=opt and opt.window
local o=kind(w)=="Window"and w:InfoPanel(opt)or newOverlay(InfoPanel,nil,opt,"InfoPanel")
o.rows=o.rows or{}
return o end
function Fawn:CreateESPPreview(opt)local w=opt and opt.window
if kind(w)=="Window"then return w:ESPPreview(opt)end
local dummy=Fawn:CreateWindow({title="FAWN PREVIEW HOST",visible=false})
local o=dummy:ESPPreview(opt)
o.window=nil
o.docked=false
return o end
function Fawn:CreateStatusBar(opt)return self:CreateWatermark(opt)end
Fawn.Watermark=Fawn.CreateWatermark
Fawn.KeybindList=Fawn.CreateKeybindList
Fawn.InfoPanel=Fawn.CreateInfoPanel
Fawn.ESPPreview=Fawn.CreateESPPreview
Fawn.ESPWindow=Fawn.CreateESPPreview
Fawn.StatusBar=Fawn.CreateStatusBar

-- Settings page
local SettingsPage={}
SettingsPage.__index=SettingsPage
local function settingsPath(path)return "C:/Serotonin/files/"..tostring(path or"Fawn Modern/configs/default.lua")end
local function serialize(v,seen)
    local t=type(v)
if t=="nil"then return"nil"elseif t=="boolean"or t=="number"then return tostring(v)elseif t=="string"then return format("%q",v)elseif t~="table"then return"nil"end
    seen=seen or{}
if seen[v]then return"nil"end
seen[v]=true
local out={"{"}
for k,x in pairs(v)do out[#out+1]="["..serialize(k,seen).."]="..serialize(x,seen)..","end
out[#out+1]="}"
seen[v]=nil
return concat(out)
end
function SettingsPage:SetConfigPath(p)self.ConfigPath=tostring(p or"Fawn Modern/configs/default.lua")
return self end
function SettingsPage:GetConfigPath()return self.ConfigPath end
function SettingsPage:CaptureDefaults()self.Defaults=self.Window:GetConfig()
return self end
function SettingsPage:SaveConfig()
    local f=type(file)=="table"and file or nil
if not f or type(f.write)~="function"then self.Window:Notify("File API unavailable",{title="CONFIG"})
return false end
local path=settingsPath(self.ConfigPath)
local dir=path:match("^(.*)/[^/]+$")
if dir and type(f.mkdir)=="function"then pcall(f.mkdir,dir)end
local ok,wrote=pcall(f.write,path,"return "..serialize(self.Window:GetConfig()))
local success=ok and wrote~=false
self.Window:Notify(success and"Config saved"or"Config save failed",{title="CONFIG"})
return success
end
function SettingsPage:LoadConfig()
    local f=type(file)=="table"and file or nil
if not f or type(f.read)~="function"then self.Window:Notify("File API unavailable",{title="CONFIG"})
return false end
local ok,str=pcall(f.read,settingsPath(self.ConfigPath))
if not ok or type(str)~="string"or str==""then self.Window:Notify("Config file not found",{title="CONFIG"})
return false end
local fn=loadfn(str)
if not fn then return false end
local ok2,data=pcall(fn)
if not ok2 or type(data)~="table"then return false end
self.Window:LoadConfig(data)
self.Window:Notify("Config loaded",{title="CONFIG"})
return true
end
function SettingsPage:ResetConfig()if self.Defaults then self.Window:LoadConfig(copy(self.Defaults))end
self.Window:Notify("Defaults restored",{title="SETTINGS"})
return self end
function SettingsPage:ShowConfigPath()self.Window:Notify(settingsPath(self.ConfigPath),{title="CONFIG PATH",duration=6})
return settingsPath(self.ConfigPath)end

function Fawn:CreateSettingsPage(window,opt)
    if window==self then window,opt=opt,nil end
    if kind(window)~="Window"and kind(window)~="Panel"then error("CreateSettingsPage requires a Fawn Window")end
    if window.settingsPage then return window.settingsPage end
    opt=type(opt)=="table"and opt or{}
    local page=setmetatable({Window=window,Controls={},ConfigPath=tostring(opt.configPath or"Fawn Modern/configs/default.lua"),Defaults=nil},SettingsPage)
    local tab=window:Tab(opt.title or"Settings",{group=opt.group or"MISCELLANEOUS",icon="misc"})
page.Tab=tab
    local appearance=tab:Section("APPEARANCE",{column=1,row=1,sizeMode="auto"})
    local behavior=tab:Section("BEHAVIOR",{column=2,row=1,sizeMode="auto"})
    local profile=tab:Section("PROFILE & BRAND",{column=1,row=2,sizeMode="auto"})
    local config=tab:Section("CONFIGURATION",{column=2,row=2,sizeMode="auto"})
    local diagnostics=tab:Section("DIAGNOSTICS",{column=1,row=3,span=2,columns=2,sizeMode="auto"})

    local ti=indexOf(Fawn.ThemeNames,window:GetThemeName())or 1
    page.Controls.Theme=appearance:Dropdown("Theme",Fawn.ThemeNames,ti,{flag="__fawn_theme",noConfig=true})
    page.Controls.Theme:OnChanged(function(v)window:SetTheme(v)end)
    page.Controls.Scale=appearance:Slider("UI Scale",55,165,round(window:GetScale()*100),{flag="__fawn_scale",noConfig=true,format=function(v)return round(v).."%"end})
    page.Controls.Scale:OnChanged(function(v)window:SetScale(v/100)end)
    page.Controls.Glass=appearance:Toggle("Liquid Glass",window:GetLiquidGlass(),{flag="__fawn_glass",noConfig=true})
    page.Controls.Glass:OnChanged(function(v)window:SetLiquidGlass(v)end)
    page.Controls.GlassOpacity=appearance:Slider("Glass Opacity",18,100,round(window:GetGlassOpacity()*100),{noConfig=true,format=function(v)return round(v).."%"end})
    page.Controls.GlassOpacity:OnChanged(function(v)window:SetGlassOpacity(v/100)end)
    page.Controls.Outline=appearance:ColorPicker("Solid Outline",window:GetOutlineColor(),{noConfig=true})
    page.Controls.Outline:OnChanged(function(v)window:SetOutlineColor(v)end)
    page.Controls.OutlineStrength=appearance:Slider("Outline Thickness",25,300,round(window:GetOutlineStrength()*100),{noConfig=true,format=function(v)return format("%.2fx",v/100)end})
    page.Controls.OutlineStrength:OnChanged(function(v)window:SetOutlineStrength(v/100)end)
    appearance:AddButton("Reset Appearance",function()window:SetTheme("Modern Blue"):SetScale(1):SetLiquidGlass(false):SetOutlineStrength(1)end)

    page.Controls.Smooth=behavior:Toggle("Smooth Scrolling",window.smoothScroll,{noConfig=true})
page.Controls.Smooth:OnChanged(function(v)window:SetSmoothScroll(v)end)
    page.Controls.Anim=behavior:Toggle("Animations",window.animations,{noConfig=true})
page.Controls.Anim:OnChanged(function(v)window:SetAnimations(v)end)
    page.Controls.ScrollSpeed=behavior:Slider("Scroll Speed",1,30,window:GetScrollSpeed(),{noConfig=true})
page.Controls.ScrollSpeed:OnChanged(function(v)window:SetScrollSpeed(v)end)
    local np=indexOf(Fawn.NotificationPositions,window:GetNotificationPosition())or 4
    page.Controls.Notifications=behavior:Dropdown("Notification Corner",Fawn.NotificationPositions,np,{noConfig=true})
page.Controls.Notifications:OnChanged(function(v)window:SetNotificationPosition(v)end)
    page.Controls.MenuKey=behavior:Keybind("Menu Key",window.toggleKey,{label=window.toggleLabel,mode="Toggle",keyboardOnly=true,keybindList=false,noConfig=true})
page.Controls.MenuKey:OnKeyChanged(function(k,l)window:SetToggleKey(k,l)end)
    behavior:AddButtonPair("Center UI",function()window:Center()end,"Default Size",function()window:SetSize(REF.Width,REF.Height)end)

    page.Controls.ProfileName=profile:Input("Username",window.profileName,{placeholder="User",noConfig=true})
page.Controls.ProfileName:OnChanged(function(v)window:SetProfileName(v)end)
    page.Controls.ProfileSub=profile:Input("Subtitle",window.profileSubtitle,{placeholder="Developer",noConfig=true})
page.Controls.ProfileSub:OnChanged(function(v)window:SetProfileSubtitle(v)end)
    page.Controls.ProfileImage=profile:Input("Profile image path",window.profileImagePath or"",{placeholder="avatar.png",noConfig=true,maxLength=260})
    profile:AddButtonPair("Apply Avatar",function()window:SetProfileImage(page.Controls.ProfileImage:Get())end,"Clear Avatar",function()window:ClearProfileImage()end)
    page.Controls.Brand=profile:Input("Brand Title",window.brand,{noConfig=true})
page.Controls.Brand:OnChanged(function(v)window.brand=v end)
    page.Controls.Subtitle=profile:Input("Brand Subtitle",window.subtitle,{noConfig=true})
page.Controls.Subtitle:OnChanged(function(v)window.subtitle=v end)
    page.Controls.LogoImage=profile:Input("Logo image path",window.logoImagePath or"",{placeholder="logo.png",noConfig=true,maxLength=260})
    profile:AddButtonPair("Apply Logo",function()window:SetLogoImage(page.Controls.LogoImage:Get())end,"Clear Logo",function()window:ClearLogoImage()end)

    page.Controls.Path=config:Input("Config Path",page.ConfigPath,{noConfig=true,maxLength=260})
page.Controls.Path:OnChanged(function(v)page:SetConfigPath(v)end)
    config:AddButtonPair("Save",function()page:SaveConfig()end,"Load",function()page:LoadConfig()end)
    config:AddButtonPair("Reset",function()page:ResetConfig()end,"Show Path",function()page:ShowConfigPath()end)
    config:AddSeparator("NAMED PROFILES")
    config:AddButtonPair("Save Current",function()window:SaveNamedConfig(window.configName)
window:Notify("Named config saved",{title="CONFIG"})end,"Duplicate",function()local n=window:DuplicateNamedConfig()
window:Notify("Created "..n,{title="CONFIG"})end)

    diagnostics:AddValue("Paint Frames",function()return Fawn:GetPaintCount()end,{controlColumn=1})
    diagnostics:AddValue("Paint Errors",function()local n=Fawn:GetPaintErrors()
return n end,{controlColumn=1})
    diagnostics:AddValue("Draw Errors",function()return E.drawErrors end,{controlColumn=2})
    diagnostics:AddValue("Window Size",function()local w,h=window:GetSize()
return round(w).." x "..round(h)end,{controlColumn=2})
    diagnostics:AddValue("Scale",function()return round(window:GetScale()*100).."%"end,{controlColumn=2})
    diagnostics:AddButton("Test Notification",function()window:Notify("Fawn Modern is rendering correctly.",{title="DIAGNOSTICS"})end,{controlColumn=2})
    page:CaptureDefaults()
window.settingsPage=page
return page
end
function Fawn:SettingsPage(a,b,c)if a==Fawn then return Fawn:CreateSettingsPage(b,c)end return Fawn:CreateSettingsPage(a,b)end
function Window:AddSettingsPage(opt)return Fawn:CreateSettingsPage(self,opt)end

-- Global library API
function Fawn:AddPreset(name,t)local n=tostring(name or"")
if n~=""and type(t)=="table"then PRESETS[n]=theme(MODERN,t)
if not indexOf(self.ThemeNames,n)then self.ThemeNames[#self.ThemeNames+1]=n end end
return self end
function Fawn:GetPreset(name)return PRESETS[name]and copy(PRESETS[name])or nil end
function Fawn:SetTheme(name)if name=="Neverlose"or name=="Fawn"then name="Modern Blue"end
if not PRESETS[name]then return self end
self.CurrentTheme=name
self.globalThemeName=name
self.globalTheme=copy(PRESETS[name])
for _,w in ipairs(E.windows)do if alive(w)and not w.independentTheme then w:SetTheme(name,true)end end
return self end
function Fawn:GetTheme()return copy(PRESETS[self.CurrentTheme or"Modern Blue"]or MODERN)end
function Fawn:GetWindows()local n={}for _,w in ipairs(E.windows)do if alive(w)then n[#n+1]=w end end return n end
function Fawn:GetOverlays()local n={}for _,o in ipairs(E.overlays)do if alive(o)then n[#n+1]=o end end return n end
function Fawn:DestroyAll()for i=#E.overlays,1,-1 do if alive(E.overlays[i])then E.overlays[i]:Destroy()end end
for i=#E.windows,1,-1 do if alive(E.windows[i])then E.windows[i]:Destroy()end end
E.notifications={}
return self end
function Fawn:GetInputState()return{mouseX=Input.mx,mouseY=Input.my,left=Input.left,right=Input.right,click=Input.click,rightClick=Input.rightClick,wheel=Input.wheel}end
function Fawn:GetColorClipboard()return copy(E.colorClipboard)end
function Fawn:SetColorClipboard(v)E.colorClipboard=rgba(v,E.colorClipboard)
return self end
function Fawn:GetPaintCount()return E.paintCount end
function Fawn:GetPaintErrors()return E.paintErrors,E.lastPaintError end
function Fawn:GetDrawErrors()return E.drawErrors,E.lastDrawError end
function Fawn:MeasureText(value,font,size)local w,h=measure(value,size or 15,font or"Verdana")
return w,h end
function Fawn:WrapText(value,maxWidth,font,maxLines,size)return wrapText(value,maxWidth,size or 15,font or"Verdana",maxLines)end
function Fawn:GetKind(object)return kind(object)end
function Fawn:Is(object,k)return kind(object)==k end
function Fawn:GetDynamicCapabilities()return{dynamicControls=true,dynamicSections=true,dynamicTabs=true,optionMutation=true,optionSources=true,visibilityRules=true,textInput=true,textWrapping=true,nestedScrolling=true,uiScale=true,liquidGlass=true,embeddedESP=true,draggableOverlays=true,namedConfigs=true}end
function Fawn:AssertCompatible()return true end


-- ==========================================================================
-- Fawn Modern compatibility surface (legacy API layer)
-- Dynamic construction, schema APIs, navigation mutation, metrics, rules,
-- object events, layout validation, state snapshots, and compatibility aliases.
-- ==========================================================================

Fawn.Layout = {
    Reference = copy(REF),
    Font = "Verdana",
    Window = {
        Width = REF.Width,
        Height = REF.Height,
        Sidebar = REF.Sidebar,
        ContentX = REF.ContentX,
        ContentTop = REF.ContentTop,
        RightMargin = REF.RightMargin,
        ColumnGap = REF.ColumnGap,
        SectionGap = REF.SectionGap,
        Top = REF.Top,
        TopHeight = REF.TopH,
        ProfileHeight = REF.ProfileH,
        ProfileBottom = REF.ProfileBottom,
        ProfileLineGap = REF.ProfileLineGap,
    },
    Full = copy(REF.Full),
    Compact = copy(REF.Compact),
}

Fawn.Padding = {
    RowLeft = REF.Full.padL,
    RowRight = REF.Full.padR,
    DropdownLeft = REF.Full.ddPadL,
    DropdownRight = REF.Full.ddPadR,
    Keybind = REF.Full.keyPad,
    Value = REF.Full.valPad,
    PopupItem = REF.Full.itemPad,
    SectionTitleTop = 30,
    PanelSide = 18,
    PanelTop = 72,
    PanelBottom = 18,
    ContentRight = REF.RightMargin,
    SidebarInner = 15,
}

Fawn.BehaviorRules = {
    ColonSyntax = true,
    DropdownIndexBase = 1,
    MultiSelectReturnsValues = true,
    MultiSelectRawReturnsBooleanArray = true,
    InputReturnsString = true,
    PasswordOnlyMasksRendering = true,
    ColorFormat = "RGBA array",
    SliderMinMaxAreVisualByDefault = true,
    SliderClampIsOptIn = true,
    AutoSectionsExpandToVisibleContent = true,
    FixedSectionsOwnInternalOverflow = true,
    FillSectionsOwnInternalOverflow = true,
    PageOwnsRemainingOverflow = true,
    NestedWheelOwnership = true,
    PopupScrollIsIndependent = true,
    PopupMustStayInsideWindow = true,
    DestroyIsTerminal = true,
    SetVisibleIsPreferredForTemporaryHiding = true,
    ScaleIsIndependentFromResize = true,
    OverlayDragUsesHeldMouseState = true,
    WindowResizeUsesHeldMouseState = true,
    TextWrapAffectsRowHeight = true,
    FontIsVerdana = true,
    NoFakeExteriorShadows = true,
    SolidOutlines = true,
    ThreeDotAccessoryMenus = true,
}

Fawn.DynamicCapabilities = {
    DynamicControls = true,
    DynamicSections = true,
    DynamicTabs = true,
    DynamicTabGroups = true,
    RuntimeTabInsertion = true,
    RuntimeTabRemoval = true,
    RuntimeTabReordering = true,
    RuntimeSectionInsertion = true,
    RuntimeSectionRemoval = true,
    RuntimeSectionReordering = true,
    RuntimeControlInsertion = true,
    RuntimeControlRemoval = true,
    RuntimeControlReordering = true,
    DeclarativeWindowSchemas = true,
    DeclarativeTabSchemas = true,
    DeclarativeSectionSchemas = true,
    DeclarativeControlSchemas = true,
    OptionMutation = true,
    OptionSources = true,
    VisibilityRules = true,
    TextInput = true,
    TextWrapping = true,
    NestedScrolling = true,
    UIScale = true,
    PhysicalResize = true,
    LiquidGlass = true,
    EmbeddedESP = true,
    DraggableOverlays = true,
    NamedConfigs = true,
    RuntimeThemes = true,
    RuntimeProfileBranding = true,
}

local function eventBucket(object)
    object._events = object._events or {}
    return object._events
end

local function objectOn(object, eventName, callback)
    if type(callback) ~= "function" then
        return object
    end
    local events = eventBucket(object)
    local name = tostring(eventName or "")
    if name == "" then
        return object
    end
    events[name] = events[name] or {}
    events[name][#events[name] + 1] = callback
    return object
end

local function objectOff(object, eventName, callback)
    local events = eventBucket(object)
    local name = tostring(eventName or "")
    local list = events[name]
    if not list then
        return object
    end
    if callback == nil then
        events[name] = nil
        return object
    end
    for i = #list, 1, -1 do
        if list[i] == callback then
            remove(list, i)
        end
    end
    if #list == 0 then
        events[name] = nil
    end
    return object
end

local function objectEmit(object, eventName, ...)
    local events = eventBucket(object)
    local list = events[tostring(eventName or "")]
    if not list then
        return object
    end
    local snapshot = arr(list)
    for _, callback in ipairs(snapshot) do
        pcall(callback, object, ...)
    end
    return object
end

local function installEvents(class)
    function class:On(eventName, callback)
        return objectOn(self, eventName, callback)
    end
    function class:Off(eventName, callback)
        return objectOff(self, eventName, callback)
    end
    function class:Emit(eventName, ...)
        return objectEmit(self, eventName, ...)
    end
    function class:ClearEvents(eventName)
        if eventName == nil then
            self._events = {}
        else
            objectOff(self, eventName, nil)
        end
        return self
    end
end

installEvents(Window)
installEvents(Tab)
installEvents(Section)
installEvents(Control)
installEvents(Overlay)
installEvents(Notification)

function Fawn:GetRules()
    return copy(self.BehaviorRules)
end

function Fawn:GetPadding()
    return copy(self.Padding)
end

function Fawn:GetReferenceMetrics()
    return copy(self.Layout)
end

function Fawn:GetDynamicCapabilities()
    return copy(self.DynamicCapabilities)
end

function Fawn:ValidateReferenceMetrics()
    local missing = {}
    local full = self.Layout and self.Layout.Full or nil
    local window = self.Layout and self.Layout.Window or nil
    if type(full) ~= "table" then
        missing[#missing + 1] = "Layout.Full"
    end
    if type(window) ~= "table" then
        missing[#missing + 1] = "Layout.Window"
    end
    local fullKeys = {
        "rowH", "font", "ctrlW", "ddH", "ddR", "ddFont",
        "ddPadL", "ddPadR", "chev", "togW", "togH", "knob",
        "sKnob", "sGap", "valH", "valPad", "valFont", "valR",
        "keyH", "keyMin", "keyMax", "keyPad", "keyFont", "keyR",
        "sw", "swR", "dots", "dotsGap", "itemH", "itemFont",
        "itemPad", "itemR", "padL", "padR",
    }
    if full then
        for _, key in ipairs(fullKeys) do
            if type(full[key]) ~= "number" then
                missing[#missing + 1] = "Layout.Full." .. key
            end
        end
    end
    return #missing == 0, missing
end

function Window:GetMetrics()
    return {
        reference = copy(Fawn.Layout),
        scale = self.scale,
        pixel = self:GetPixelMetrics(),
        padding = copy(Fawn.Padding),
    }
end

function Window:ResetReferenceMetrics()
    self.scale = 1
    self.corner = 22
    self.borderThickness = 1
    self.outlineStrength = 1
    self:_closePopups()
    return self
end

function Window:SetMinimumSize(width, height)
    self.minWidth = max(320, tonumber(width) or self.minWidth)
    self.minHeight = max(220, tonumber(height) or self.minHeight)
    self:SetSize(self.width, self.height)
    return self
end

function Window:GetMinimumSize()
    return self.minWidth, self.minHeight
end

function Window:SetMaximumSize(width, height)
    self.maxWidth = max(self.minWidth, tonumber(width) or self.maxWidth)
    self.maxHeight = max(self.minHeight, tonumber(height) or self.maxHeight)
    self:SetSize(self.width, self.height)
    return self
end

function Window:GetMaximumSize()
    return self.maxWidth, self.maxHeight
end

function Window:SetResizable(value)
    self.resizable = value ~= false
    if not self.resizable then
        self.resizing = nil
    end
    return self
end

function Window:GetResizable()
    return self.resizable ~= false
end

function Window:SetDraggable(value)
    self.draggable = value ~= false
    if not self.draggable then
        self.dragging = nil
    end
    return self
end

function Window:GetDraggable()
    return self.draggable ~= false
end

function Window:SetTitle(value)
    self.brand = tostring(value or "")
    self:Emit("brandingChanged", "title", self.brand)
    return self
end

function Window:GetTitle()
    return self.brand
end

function Window:SetSubtitle(value)
    self.subtitle = tostring(value or "")
    self:Emit("brandingChanged", "subtitle", self.subtitle)
    return self
end

function Window:GetSubtitle()
    return self.subtitle
end

function Window:SetLogoText(value)
    self.logo = tostring(value or "")
    self:Emit("brandingChanged", "logo", self.logo)
    return self
end

function Window:GetLogoText()
    return self.logo
end

function Window:GetProfile()
    return {
        name = self.profileName,
        subtitle = self.profileSubtitle,
        image = self.profileImagePath,
    }
end

function Window:SetProfile(profile)
    profile = type(profile) == "table" and profile or {}
    if profile.name ~= nil then
        self:SetProfileName(profile.name)
    end
    if profile.subtitle ~= nil then
        self:SetProfileSubtitle(profile.subtitle)
    end
    if profile.image ~= nil then
        self:SetProfileImage(profile.image)
    end
    return self
end

function Window:AddProfileMenuItem(label, callback, options)
    local item = {
        label = tostring(label or "Item"),
        callback = type(callback) == "function" and callback or nil,
        icon = type(options) == "table" and options.icon or nil,
        danger = type(options) == "table" and options.danger == true or false,
        visible = type(options) ~= "table" or options.visible ~= false,
    }
    self.profileMenuItems[#self.profileMenuItems + 1] = item
    return item
end

function Window:RemoveProfileMenuItem(which)
    local item = nil
    if type(which) == "number" then
        item = self.profileMenuItems[which]
    else
        for _, candidate in ipairs(self.profileMenuItems) do
            if candidate == which or candidate.label == which then
                item = candidate
                break
            end
        end
    end
    if item then
        removeValue(self.profileMenuItems, item)
    end
    return self
end

function Window:ClearProfileMenuItems()
    self.profileMenuItems = {}
    return self
end

function Window:GetProfileMenuItems()
    return self.profileMenuItems
end

function Window:AddGroup(value, index)
    local name = tostring(value or "")
    if name == "" or indexOf(self.groups, name) then
        return self
    end
    if index then
        insert(self.groups, clamp(floor(tonumber(index) or 1), 1, #self.groups + 1), name)
    else
        self.groups[#self.groups + 1] = name
    end
    self:Emit("groupListChanged", self.groups)
    return self
end

function Window:RemoveGroup(value)
    local i = indexOf(self.groups, value)
    if not i then
        return self
    end
    remove(self.groups, i)
    if self.group == value then
        self.group = self.groups[1] or "Global"
    end
    self:Emit("groupListChanged", self.groups)
    return self
end

function Window:MoveGroup(value, index)
    local i = indexOf(self.groups, value)
    if not i then
        return self
    end
    local name = remove(self.groups, i)
    insert(self.groups, clamp(floor(tonumber(index) or 1), 1, #self.groups + 1), name)
    self:Emit("groupListChanged", self.groups)
    return self
end

function Window:GetGroups()
    return arr(self.groups)
end

function Window:ClearGroups()
    self.groups = { "Global" }
    self.group = "Global"
    self:Emit("groupListChanged", self.groups)
    return self
end

function Tab:SetName(value)
    self.name = tostring(value or "Tab")
    if self.window then
        self.window:Emit("tabChanged", self, "name")
    end
    return self
end

function Tab:GetName()
    return self.name
end

function Tab:SetIcon(value)
    self.icon = value or "circle"
    if self.window then
        self.window:Emit("tabChanged", self, "icon")
    end
    return self
end

function Tab:GetIcon()
    return self.icon
end

function Tab:SetGroup(value)
    self.group = tostring(value or "MAIN")
    if self.window then
        self.window:Emit("tabChanged", self, "group")
    end
    return self
end

function Tab:GetGroup()
    return self.group
end

function Tab:SetOrder(index)
    if self.window then
        self.window:MoveTab(self, index)
    end
    return self
end

function Tab:MoveBefore(other)
    if not self.window or not other then
        return self
    end
    local i = indexOf(self.window.tabs, other)
    if i then
        self.window:MoveTab(self, i)
    end
    return self
end

function Tab:MoveAfter(other)
    if not self.window or not other then
        return self
    end
    local i = indexOf(self.window.tabs, other)
    if i then
        self.window:MoveTab(self, i + 1)
    end
    return self
end

function Tab:GetWindow()
    return self.window
end

function Tab:GetIndex()
    return self.window and indexOf(self.window.tabs, self) or nil
end

function Window:GetTabsInGroup(groupName)
    local output = {}
    for _, tab in ipairs(self.tabs) do
        if alive(tab) and tab.group == groupName then
            output[#output + 1] = tab
        end
    end
    return output
end

function Window:GetTabGroups()
    local seen = {}
    local output = {}
    for _, tab in ipairs(self.tabs) do
        if alive(tab) and not seen[tab.group] then
            seen[tab.group] = true
            output[#output + 1] = tab.group
        end
    end
    return output
end

function Window:FindTab(predicate)
    if type(predicate) == "string" or type(predicate) == "number" then
        return self:GetTab(predicate)
    end
    if type(predicate) ~= "function" then
        return nil
    end
    for index, tab in ipairs(self.tabs) do
        if alive(tab) then
            local ok, matched = pcall(predicate, tab, index, self)
            if ok and matched then
                return tab
            end
        end
    end
end

function Window:ForEachTab(callback)
    if type(callback) ~= "function" then
        return self
    end
    local snapshot = self:GetTabs()
    for index, tab in ipairs(snapshot) do
        callback(tab, index, self)
    end
    return self
end

function Window:ForEachSection(callback)
    if type(callback) ~= "function" then
        return self
    end
    self:ForEachTab(function(tab)
        for index, section in ipairs(tab:GetSections()) do
            callback(section, tab, index, self)
        end
    end)
    return self
end

function Window:FindSection(predicate)
    if type(predicate) == "string" then
        local result = nil
        self:ForEachSection(function(section)
            if result == nil and (section.name == predicate or section.id == predicate) then
                result = section
            end
        end)
        return result
    end
    if type(predicate) ~= "function" then
        return nil
    end
    local result = nil
    self:ForEachSection(function(section, tab, index)
        if result ~= nil then
            return
        end
        local ok, matched = pcall(predicate, section, tab, index, self)
        if ok and matched then
            result = section
        end
    end)
    return result
end

function Window:FindControl(predicate)
    if type(predicate) == "string" then
        return self:GetControl(predicate)
    end
    if type(predicate) ~= "function" then
        return nil
    end
    local result = nil
    self:ForEachControl(function(control, section, tab)
        if result ~= nil then
            return
        end
        local ok, matched = pcall(predicate, control, section, tab, self)
        if ok and matched then
            result = control
        end
    end)
    return result
end

function Section:SetName(value)
    self.name = tostring(value or "SECTION")
    return self
end

function Section:GetName()
    return self.name
end

function Section:GetTab()
    return self.tab
end

function Section:GetWindow()
    return self.window
end

function Section:GetIndex()
    return self.tab and indexOf(self.tab.sections, self) or nil
end

function Section:InsertControl(index, control)
    if not alive(control) then
        return self
    end
    if control.section ~= self then
        error("InsertControl only reorders controls already owned by this Section")
    end
    return self:MoveControl(control, index)
end

function Section:FindControl(predicate)
    if type(predicate) == "string" or type(predicate) == "number" then
        return self:GetControl(predicate)
    end
    if type(predicate) ~= "function" then
        return nil
    end
    for index, control in ipairs(self.controls) do
        if alive(control) then
            local ok, matched = pcall(predicate, control, index, self)
            if ok and matched then
                return control
            end
        end
    end
end

function Section:ForEachControl(callback)
    if type(callback) ~= "function" then
        return self
    end
    local snapshot = self:GetControls()
    for index, control in ipairs(snapshot) do
        callback(control, index, self)
    end
    return self
end

function Control:GetSection()
    return self.section
end

function Control:GetWindow()
    return self.window
end

function Control:GetIndex()
    if self.type == "dropdown" then
        return self.value
    end
    return self.section and indexOf(self.section.controls, self) or nil
end

function Control:GetControlIndex()
    return self.section and indexOf(self.section.controls, self) or nil
end

function Control:SetTooltip(value)
    self.tooltip = value == nil and nil or tostring(value)
    return self
end

function Control:GetTooltip()
    return self.tooltip
end

function Control:SetDescription(value)
    self.description = value == nil and nil or tostring(value)
    return self
end

function Control:GetDescription()
    return self.description
end

function Control:SetNoConfig(value)
    self.noConfig = value == true
    return self
end

function Control:GetNoConfig()
    return self.noConfig == true
end

function Control:SetSummaryMode(mode, maxItems)
    if self.type == "multiselect" then
        local m = tostring(mode or "auto")
        if m == "auto" or m == "count" or m == "items" then
            self.summaryMode = m
        end
        if maxItems ~= nil then
            self.summaryItems = max(1, floor(tonumber(maxItems) or 2))
        end
    end
    return self
end

function Control:GetSummaryMode()
    return self.summaryMode, self.summaryItems
end

function Control:SetNoneText(value)
    self.noneText = tostring(value or "None")
    return self
end

function Control:GetNoneText()
    return self.noneText or "None"
end

function Control:SetFormat(callback)
    if self.type == "slider" then
        self.format = type(callback) == "function" and callback or nil
    end
    return self
end

function Control:GetFormat()
    return self.format
end

function Control:SetStep(value)
    if self.type == "slider" then
        local n = tonumber(value)
        self.step = n and max(0, n) or nil
    end
    return self
end

function Control:GetStep()
    return self.step
end

local function schemaOptions(definition)
    local options = copy(type(definition.options) == "table" and definition.options or {})
    local inherited = {
        "flag", "visible", "disabled", "callback", "column", "row", "span",
        "controlColumn", "controlRow", "controlSpan", "wrap", "maxLines",
        "lineHeight", "noConfig", "placeholder", "maxLength", "numeric",
        "allowFloat", "allowNegative", "password", "mode", "label",
        "keyboardOnly", "keybindList", "maxVisibleOptions", "summaryMode",
        "summaryItems", "noneText", "clamp", "float", "format", "unit",
        "zero", "colorPicker", "keybind", "accent", "muted",
    }
    for _, key in ipairs(inherited) do
        if definition[key] ~= nil and options[key] == nil then
            options[key] = definition[key]
        end
    end
    return options
end

local function createControlFromDefinition(section, definition)
    if type(definition) ~= "table" then
        return nil
    end
    local typeName = lower(tostring(definition.type or definition.kind or definition.control or ""))
    local label = definition.label or definition.text or definition.name or ""
    local options = schemaOptions(definition)
    if typeName == "toggle" or typeName == "checkbox" then
        return section:AddToggle(label, definition.default == true or definition.value == true, options)
    elseif typeName == "togglekeybind" or typeName == "toggle_keybind" then
        local default = definition.default == true or definition.value == true
        local key = definition.key or options.key or ""
        return section:AddToggleKeybind(label, default, key, options)
    elseif typeName == "slider" then
        local minValue = tonumber(definition.min) or 0
        local maxValue = tonumber(definition.max) or 100
        local default = definition.default
        if default == nil then
            default = definition.value
        end
        if default == nil then
            default = minValue
        end
        return section:AddSlider(label, minValue, maxValue, default, options)
    elseif typeName == "dropdown" or typeName == "combo" then
        local values = definition.values or definition.items or definition.optionsList or definition.list or {}
        local default = definition.default or definition.value or definition.index or 1
        return section:AddDropdown(label, values, default, options)
    elseif typeName == "multiselect" or typeName == "multidropdown" or typeName == "multi" then
        local values = definition.values or definition.items or definition.optionsList or definition.list or {}
        local default = definition.default or definition.value or {}
        return section:AddMultiSelect(label, values, default, options)
    elseif typeName == "input" or typeName == "textbox" or typeName == "textinput" then
        local default = definition.default
        if default == nil then
            default = definition.value
        end
        return section:AddInput(label, default or "", options)
    elseif typeName == "color" or typeName == "colorpicker" then
        local default = definition.default or definition.value or { 255, 255, 255, 255 }
        return section:AddColorPicker(label, default, options)
    elseif typeName == "keybind" or typeName == "hotkey" then
        local key = definition.key or definition.default or definition.value or ""
        return section:AddKeybind(label, key, options)
    elseif typeName == "button" then
        return section:AddButton(label, definition.callback or definition.onClick, options)
    elseif typeName == "buttonpair" or typeName == "button_pair" then
        return section:AddButtonPair(
            definition.leftText or definition.left or "Left",
            definition.leftCallback or definition.onLeft,
            definition.rightText or definition.right or "Right",
            definition.rightCallback or definition.onRight,
            options
        )
    elseif typeName == "label" then
        return section:AddLabel(label, options)
    elseif typeName == "separator" then
        return section:AddSeparator(label, options)
    elseif typeName == "spacer" then
        return section:AddSpacer(definition.height or definition.value or 18, options)
    elseif typeName == "value" or typeName == "inforow" or typeName == "info" then
        local source = definition.valueSource
        if source == nil then
            source = definition.value
        end
        return section:AddValue(label, source, options)
    end
    return nil
end

function Section:CreateControl(definition)
    return createControlFromDefinition(self, definition)
end

function Section:CreateControls(definitions)
    local output = {}
    for _, definition in ipairs(type(definitions) == "table" and definitions or {}) do
        local control = self:CreateControl(definition)
        if control then
            output[#output + 1] = control
        end
    end
    return output
end

function Section:RebuildControls(definitions)
    self:ClearControls()
    return self:CreateControls(definitions)
end

function Section:ExportSchema()
    local schema = {
        name = self.name,
        column = self.column,
        row = self.row,
        span = self.span,
        columns = self.columns,
        controlGap = self.controlGap,
        sizeMode = self.sizeMode,
        height = self.height,
        minHeight = self.minHeight,
        maxHeight = self.maxHeight,
        visible = self.visible,
        controls = {},
    }
    for _, control in ipairs(self:GetControls()) do
        local c = {
            type = control.type,
            label = control.label,
            flag = control.flag,
            visible = control.visible,
            disabled = control.disabled,
            column = control.column,
            row = control.row,
            span = control.span,
            wrap = control.wrap,
            maxLines = control.maxLines,
            lineHeight = control.lineHeight,
            noConfig = control.noConfig,
        }
        if control.type == "slider" then
            c.min = control.min
            c.max = control.max
            c.value = control.value
            c.clamp = control.clampValue
            c.float = control.float
        elseif control.type == "dropdown" then
            c.values = arr(control.options)
            c.value = control.value
        elseif control.type == "multiselect" then
            c.values = arr(control.options)
            c.value = control:Get()
        elseif control.type == "input" then
            c.value = control.value
            c.placeholder = control.placeholder
            c.maxLength = control.maxLength
            c.numeric = control.numeric
            c.password = control.password
        elseif control.type == "color" then
            c.value = copy(control.value)
        elseif control.type == "keybind" then
            c.key = control.key
            c.mode = control.mode
            c.keybindList = control.keybindList
        elseif control.type == "toggle" then
            c.value = control.value
        elseif control.type == "label" then
            c.text = control.label
        elseif control.type == "spacer" then
            c.height = control.height
        elseif control.type == "value" then
            c.value = control.valueSource
        end
        schema.controls[#schema.controls + 1] = c
    end
    return schema
end

function Tab:CreateSection(definition)
    if type(definition) == "string" then
        return self:AddSection(definition)
    end
    if type(definition) ~= "table" then
        return nil
    end
    local options = copy(definition.options or {})
    local fields = {
        "column", "row", "span", "columns", "controlGap", "height",
        "sizeMode", "heightMode", "autoSize", "autosize", "fillHeight",
        "minHeight", "maxHeight", "visible", "scrollStep",
    }
    for _, key in ipairs(fields) do
        if definition[key] ~= nil and options[key] == nil then
            options[key] = definition[key]
        end
    end
    local section = self:AddSection(definition.name or definition.title or "SECTION", options)
    if definition.controls then
        section:CreateControls(definition.controls)
    end
    return section
end

function Tab:CreateSections(definitions)
    local output = {}
    for _, definition in ipairs(type(definitions) == "table" and definitions or {}) do
        local section = self:CreateSection(definition)
        if section then
            output[#output + 1] = section
        end
    end
    return output
end

function Tab:RebuildSections(definitions)
    self:ClearSections()
    return self:CreateSections(definitions)
end

function Tab:ExportSchema()
    local schema = {
        name = self.name,
        group = self.group,
        icon = self.icon,
        visible = self.visible,
        selected = self.window and self.window.activeTab == self or false,
        mainScrollEnabled = self.mainScrollEnabled,
        scrollStep = self.scrollStep,
        sections = {},
    }
    for _, section in ipairs(self:GetSections()) do
        schema.sections[#schema.sections + 1] = section:ExportSchema()
    end
    return schema
end

function Window:CreateTab(definition, options)
    if type(definition) == "string" then
        return self:Tab(definition, options)
    end
    if type(definition) ~= "table" then
        return nil
    end
    local tabOptions = copy(definition.options or {})
    local fields = { "group", "icon", "visible", "selected", "mainScrollEnabled", "scrollStep" }
    for _, key in ipairs(fields) do
        if definition[key] ~= nil and tabOptions[key] == nil then
            tabOptions[key] = definition[key]
        end
    end
    local tab = self:Tab(definition.name or definition.title or "Tab", tabOptions)
    if definition.sections then
        tab:CreateSections(definition.sections)
    end
    return tab
end

function Window:CreateTabs(definitions)
    local output = {}
    for _, definition in ipairs(type(definitions) == "table" and definitions or {}) do
        local tab = self:CreateTab(definition)
        if tab then
            output[#output + 1] = tab
        end
    end
    return output
end

function Window:RebuildTabs(definitions, selected)
    self:ClearTabs()
    local tabs = self:CreateTabs(definitions)
    if selected ~= nil then
        self:SelectTab(selected)
    elseif #tabs > 0 then
        if self.activeTab and indexOf(tabs, self.activeTab) then
            self:SelectTab(self.activeTab)
        else
            self:SelectTab(tabs[1])
        end
    end
    self:Emit("tabsRebuilt", tabs)
    return tabs
end

function Window:ExportSchema()
    local schema = {
        title = self.brand,
        subtitle = self.subtitle,
        logo = self.logo,
        width = self.width,
        height = self.height,
        minWidth = self.minWidth,
        minHeight = self.minHeight,
        maxWidth = self.maxWidth,
        maxHeight = self.maxHeight,
        x = self.x,
        y = self.y,
        scale = self.scale,
        columns = self.columns,
        theme = self.themeName,
        liquidGlass = self.liquidGlass,
        glassOpacity = self.glassOpacity,
        toggleKey = self.toggleKey,
        groups = arr(self.groups),
        group = self.group,
        profile = self:GetProfile(),
        tabs = {},
    }
    for _, tab in ipairs(self:GetTabs()) do
        schema.tabs[#schema.tabs + 1] = tab:ExportSchema()
    end
    return schema
end

function Window:ApplySchema(schema, options)
    if type(schema) ~= "table" then
        return self
    end
    options = type(options) == "table" and options or {}
    if schema.title ~= nil then
        self:SetTitle(schema.title)
    end
    if schema.subtitle ~= nil then
        self:SetSubtitle(schema.subtitle)
    end
    if schema.logo ~= nil then
        self:SetLogoText(schema.logo)
    end
    if schema.profile then
        self:SetProfile(schema.profile)
    end
    if schema.groups then
        self:SetGroups(schema.groups, schema.group)
    elseif schema.group then
        self:SetGroup(schema.group)
    end
    if schema.theme then
        self:SetTheme(schema.theme)
    end
    if schema.scale then
        self:SetScale(schema.scale)
    end
    if schema.columns then
        self:SetColumns(schema.columns)
    end
    if schema.width or schema.height then
        self:SetSize(schema.width or self.width, schema.height or self.height)
    end
    if schema.x or schema.y then
        self:SetPosition(schema.x or self.x, schema.y or self.y)
    end
    if schema.liquidGlass ~= nil then
        self:SetLiquidGlass(schema.liquidGlass)
    end
    if schema.glassOpacity then
        self:SetGlassOpacity(schema.glassOpacity)
    end
    if schema.toggleKey then
        self:SetToggleKey(schema.toggleKey, schema.toggleLabel)
    end
    if schema.tabs then
        if options.replaceTabs == false then
            self:CreateTabs(schema.tabs)
        else
            self:RebuildTabs(schema.tabs, options.selectedTab or schema.selectedTab)
        end
    end
    self:Emit("schemaApplied", schema, options)
    return self
end

function Fawn:CreateFromSchema(schema)
    if type(schema) ~= "table" then
        error("CreateFromSchema requires a schema table")
    end
    local options = copy(schema)
    options.tabs = nil
    options.profile = nil
    local window = self:CreateWindow(options)
    window:ApplySchema(schema, { replaceTabs = true, selectedTab = schema.selectedTab })
    return window
end

function Fawn:CreatePanelFromSchema(schema)
    if type(schema) ~= "table" then
        error("CreatePanelFromSchema requires a schema table")
    end
    local options = copy(schema)
    options.tabs = nil
    options.profile = nil
    local panel = self:CreatePanel(options)
    panel:ApplySchema(schema, { replaceTabs = true, selectedTab = schema.selectedTab })
    return panel
end

function Window:SnapshotState()
    return {
        position = { self:GetPosition() },
        size = { self:GetSize() },
        scale = self:GetScale(),
        visible = self.visible,
        theme = self:GetThemeName(),
        selectedTab = self.activeTab and self.activeTab.id or nil,
        group = self.group,
        config = self:GetConfig(),
    }
end

function Window:RestoreState(snapshot, silent)
    if type(snapshot) ~= "table" then
        return self
    end
    if type(snapshot.position) == "table" then
        self:SetPosition(snapshot.position[1], snapshot.position[2])
    end
    if type(snapshot.size) == "table" then
        self:SetSize(snapshot.size[1], snapshot.size[2])
    end
    if snapshot.scale then
        self:SetScale(snapshot.scale)
    end
    if snapshot.theme then
        self:SetTheme(snapshot.theme)
    end
    if snapshot.group then
        self:SetGroup(snapshot.group)
    end
    if snapshot.config then
        self:LoadConfig(snapshot.config, silent)
    end
    if snapshot.selectedTab then
        self:SelectTab(snapshot.selectedTab)
    end
    if snapshot.visible ~= nil then
        self:SetVisible(snapshot.visible)
    end
    return self
end

function Window:CloneSchema()
    return copy(self:ExportSchema())
end

function Fawn:ValidateObjectTree(window)
    local errors = {}
    if kind(window) ~= "Window" and kind(window) ~= "Panel" then
        return false, { "Expected Window or Panel" }
    end
    local seenFlags = {}
    for ti, tab in ipairs(window.tabs) do
        if tab.destroyed then
            errors[#errors + 1] = "Destroyed tab still present at index " .. ti
        end
        if tab.window ~= window then
            errors[#errors + 1] = "Tab parent mismatch: " .. tostring(tab.name)
        end
        for si, section in ipairs(tab.sections) do
            if section.tab ~= tab then
                errors[#errors + 1] = "Section parent mismatch: " .. tostring(section.name)
            end
            if section.window ~= window then
                errors[#errors + 1] = "Section window mismatch: " .. tostring(section.name)
            end
            for ci, control in ipairs(section.controls) do
                if control.section ~= section then
                    errors[#errors + 1] = "Control parent mismatch: " .. tostring(control.label)
                end
                if control.window ~= window then
                    errors[#errors + 1] = "Control window mismatch: " .. tostring(control.label)
                end
                if control.flag then
                    if seenFlags[control.flag] and seenFlags[control.flag] ~= control then
                        errors[#errors + 1] = "Duplicate control flag: " .. tostring(control.flag)
                    end
                    seenFlags[control.flag] = control
                end
                if control.type == "dropdown" and #control.options > 0 then
                    if control.value < 1 or control.value > #control.options then
                        errors[#errors + 1] = "Dropdown index outside one-based range: " .. tostring(control.label)
                    end
                end
                if control.type == "multiselect" and #control.value ~= #control.options then
                    errors[#errors + 1] = "MultiSelect raw array length mismatch: " .. tostring(control.label)
                end
            end
        end
    end
    return #errors == 0, errors
end

function Window:ValidateTree()
    return Fawn:ValidateObjectTree(self)
end

function Fawn:GetStats()
    local windows = self:GetWindows()
    local overlays = self:GetOverlays()
    local tabs, sections, controls = 0, 0, 0
    for _, window in ipairs(windows) do
        tabs = tabs + window:GetTabCount()
        window:ForEachSection(function(section)
            sections = sections + 1
            controls = controls + section:GetControlCount()
        end)
    end
    return {
        windows = #windows,
        overlays = #overlays,
        tabs = tabs,
        sections = sections,
        controls = controls,
        paintCount = E.paintCount,
        paintErrors = E.paintErrors,
        drawErrors = E.drawErrors,
    }
end

-- Compatibility aliases that are deliberately explicit in the fresh rewrite.
Window.Section = Window.AddSection
Window.Toggle = Window.AddToggle
Window.ToggleControl = Window.AddToggle
Window.AddToggleKeybind = Window.AddToggleKeybind
Window.AddLabel = Window.AddLabel
Window.AddSeparator = Window.AddSeparator
Window.AddSpacer = Window.AddSpacer
Window.AddValue = Window.AddValue
Window.ToggleKeybind = Window.AddToggleKeybind
Window.Slider = Window.AddSlider
Window.Dropdown = Window.AddDropdown
Window.MultiSelect = Window.AddMultiSelect
Window.Input = Window.AddInput
Window.ColorPicker = Window.AddColorPicker
Window.Keybind = Window.AddKeybind
Window.Button = Window.AddButton
Window.ButtonPair = Window.AddButtonPair
Window.Label = Window.AddLabel
Window.Separator = Window.AddSeparator
Window.Spacer = Window.AddSpacer
Window.Value = Window.AddValue
Window.SettingsPage = Window.AddSettingsPage
Window.Remove = Window.Destroy

Tab.Toggle = Tab.AddToggle
Tab.ToggleKeybind = Tab.AddToggleKeybind
Tab.AddToggleKeybind = Tab.AddToggleKeybind
Tab.AddLabel = Tab.AddLabel
Tab.AddSeparator = Tab.AddSeparator
Tab.AddSpacer = Tab.AddSpacer
Tab.AddValue = Tab.AddValue
Tab.Slider = Tab.AddSlider
Tab.Dropdown = Tab.AddDropdown
Tab.MultiSelect = Tab.AddMultiSelect
Tab.Input = Tab.AddInput
Tab.ColorPicker = Tab.AddColorPicker
Tab.Keybind = Tab.AddKeybind
Tab.Button = Tab.AddButton
Tab.ButtonPair = Tab.AddButtonPair
Tab.Label = Tab.AddLabel
Tab.Separator = Tab.AddSeparator
Tab.Spacer = Tab.AddSpacer
Tab.Value = Tab.AddValue
Tab.Remove = Tab.Destroy

Watermark.Remove = Overlay.Destroy
InfoPanel.UpdateRow = InfoPanel.SetRow
Fawn.CreateESPWindow = Fawn.CreateESPPreview


local REQUIRED={
    Fawn={"CreateWindow","CreatePanel","Notify","AddPreset","GetPreset","GetWindows","GetOverlays","DestroyAll","GetInputState","Validate","AssertCompatible","GetPaintCount","GetPaintErrors","SetTheme","GetTheme","WrapText","MeasureText","GetDynamicCapabilities","CreateSettingsPage","CreateFromSchema","CreatePanelFromSchema","GetRules","GetPadding","GetReferenceMetrics","ValidateReferenceMetrics","ValidateObjectTree","GetStats"},
    Window={"SetVisible","Toggle","Tab","SelectTab","SetPosition","GetPosition","SetSize","GetSize","SetScale","GetScale","GetConfig","LoadConfig","AddSection","Watermark","KeybindList","InfoPanel","ESPPreview","Notify","SetColumns","SetTheme","SetStyle","GetStyle","GetTabs","RemoveTab","InsertTab","SetMainScrollEnabled","CreateTab","CreateTabs","RebuildTabs","ApplySchema","ExportSchema","FindTab","ForEachTab","FindSection","ForEachSection","FindControl","ValidateTree"},
    Section={"Toggle","Slider","Dropdown","MultiSelect","Input","ColorPicker","Keybind","Button","ButtonPair","Label","Separator","Spacer","Value","SetSizeMode","SetColumns","SetVisible","ScrollTo","GetControls","RemoveControl","Destroy","CreateControl","CreateControls","RebuildControls","ExportSchema","FindControl","ForEachControl"},
    Control={"Get","GetRaw","Set","SetVisible","SetDisabled","SetText","SetFlag","GetFlag","SetOptions","SetMode","SetKey","SetClamp","Destroy","ShowWhen","SetWrap","SetMaxLines","ClearKey","SetOptionsSource","GetSelected","SetPlaceholder","Focus","SetMaxVisibleOptions"}
}
function Fawn:Validate()
    local missing={}
local maps={Fawn=self,Window=Window,Section=Section,Control=Control}
for cn,list in pairs(REQUIRED)do local m=maps[cn]
for _,n in ipairs(list)do if type(m[n])~="function"then missing[#missing+1]=cn..":"..n end end end
return#missing==0,missing
end

local function factoryParent(a,b)
    if a==Fawn then return b end
return a
end
function Fawn:Tab(a,b,c)local p=a==Fawn and b or a
local name=a==Fawn and c or b
if kind(p)=="Window"or kind(p)=="Panel"then return p:Tab(name)end end
function Fawn:Section(a,b,c,d)local p=a==Fawn and b or a
local name=a==Fawn and c or b
local opt=a==Fawn and d or c
if kind(p)=="Tab"then return p:Section(name,opt)elseif kind(p)=="Window"or kind(p)=="Panel"then return p:AddSection(name,opt)end end
local FACTORY_NAMES={"Toggle","ToggleKeybind","Slider","Dropdown","MultiSelect","Input","ColorPicker","Keybind","Button","ButtonPair","Label","Separator","Spacer","Value"}
for _,n in ipairs(FACTORY_NAMES)do Fawn[n]=function(a,b,...)local p,args
if a==Fawn then p=b
args={...}else p=a
args={b,...}end
if kind(p)=="Section"then return p[n](p,unpack(args))elseif kind(p)=="Tab"then return p["Add"..n](p,unpack(args))elseif kind(p)=="Window"or kind(p)=="Panel"then return p["Add"..n](p,unpack(args))end end end

Fawn.AddTab=Fawn.Tab
Fawn.CreateTab=Fawn.Tab
Fawn.AddSection=Fawn.Section
Fawn.CreateSection=Fawn.Section
Fawn.AddToggle=Fawn.Toggle
Fawn.Checkbox=Fawn.Toggle
Fawn.AddToggleKeybind=Fawn.ToggleKeybind
Fawn.AddSlider=Fawn.Slider
Fawn.AddDropdown=Fawn.Dropdown
Fawn.Combo=Fawn.Dropdown
Fawn.AddMultiSelect=Fawn.MultiSelect
Fawn.MultiDropdown=Fawn.MultiSelect
Fawn.AddMultiDropdown=Fawn.MultiSelect
Fawn.AddInput=Fawn.Input
Fawn.Textbox=Fawn.Input
Fawn.AddTextbox=Fawn.Input
Fawn.TextInput=Fawn.Input
Fawn.AddTextInput=Fawn.Input
Fawn.AddColorPicker=Fawn.ColorPicker
Fawn.Color=Fawn.ColorPicker
Fawn.AddKeybind=Fawn.Keybind
Fawn.Hotkey=Fawn.Keybind
Fawn.AddButton=Fawn.Button
Fawn.AddButtonPair=Fawn.ButtonPair
Fawn.AddLabel=Fawn.Label
Fawn.AddSeparator=Fawn.Separator
Fawn.AddSpacer=Fawn.Spacer
Fawn.AddValue=Fawn.Value
Fawn.InfoRow=Fawn.Value
Fawn.AddInfoRow=Fawn.Value
Fawn.Classes={Window=Window,Panel=Window,Tab=Tab,Section=Section,Control=Control,Overlay=Overlay,Watermark=Watermark,KeybindList=KeybindList,InfoPanel=InfoPanel,ESPPreview=ESPPreview,Notification=Notification,SettingsPage=SettingsPage}
Fawn.Components={Window=Fawn.Window,Panel=Fawn.Panel,Watermark=Fawn.Watermark,KeybindList=Fawn.KeybindList,InfoPanel=Fawn.InfoPanel,ESPPreview=Fawn.ESPPreview,Notify=Fawn.Notify}
Fawn.Reference=copy(REF)
Fawn.CurrentTheme="Modern Blue"
Fawn.globalThemeName="Modern Blue"
Fawn.globalTheme=copy(PRESETS["Modern Blue"])


-- Compatibility layer: layout/input/ESP stability -------------------------------------
Fawn.Runtime=Fawn.Runtime or {}
Fawn.Style.ContainerClip=true
Fawn.Style.ReferenceAccessoryPopups=true
Fawn.Style.FawnHSVColorPicker=true
Fawn.Style.ResponsiveDockedESP=true
Fawn.Rules.FixedFillSectionsOwnOverflow=true
Fawn.Rules.AutoSectionsExpand=true
Fawn.Rules.PageClipsToWindow=true
Fawn.Rules.ResizePreservesAnchors=true

-- Reference-like embedded keybind accessory: outer dots -> Keybind row -> inner dots for mode.
function Window:_drawEmbeddedKeybindDots(parent,right,cy,F,interactive)
    local s=self.scale
    local dx=right-F.dots*s
    local hs=F.dots*2*s
    local hx,hy=dx-F.dots*s,cy-F.dots*s
    local open=self.extraPopup and self.extraPopup.control==parent
    self:_icon("dots",dx,cy,F.dots*s,open and"text"or"muted")
    if interactive and Input.click and not self._consumed and(not self:_hasPopup()or open)and self:_hit(hx,hy,hs,hs)then
        if open then
            self.extraPopup=nil;self.openDrop=nil;self.keyMenu=nil;self.colorPopup=nil;self.colorMenu=nil
        else
            self.extraPopup={control=parent,x=right-330*s,y=cy+F.dots*s+8*s,w=330*s,h=76*s,anchorY=cy-F.dots*s,triggerX=hx,triggerY=hy,triggerW=hs,triggerH=hs}
        end
        self:_consume()
    end
    return hx
end

local _hasPopup92=Window._hasPopup
function Window:_hasPopup()
    return self.openDrop or self.extraPopup or self.keyMenu or self.colorPopup or self.colorMenu or self.configPopup or self.groupPopup or self.accountOpen
end
local _closePopups92=Window._closePopups
function Window:_closePopups()
    self.openDrop=nil;self.extraPopup=nil;self.keyMenu=nil;self.colorPopup=nil;self.colorMenu=nil
    self.configPopup=nil;self.groupPopup=nil;self.accountOpen=false;self.searchOpen=false;self.searchEdit=nil
    return self
end

function Window:_drawExtraPopup()
    local p=self.extraPopup
    if not p then return end
    local parent=p.control
    if not alive(parent) or not alive(parent.keybind) then self.extraPopup=nil return end
    local s=self.scale;local C=REF.Compact;local k=parent.keybind
    p.w=330*s;p.h=76*s;p.anchorY=p.anchorY or p.y-8*s
    self:_clampPopup(p);self:_popupFrame(p)
    textC("KEYBIND",p.x+14*s,p.y+18*s,self:_color("muted"),13*s,"Verdana")
    local cy=p.y+50*s
    textC("Key",p.x+C.padL*s,cy,self:_color("text"),C.font*s,"Verdana")
    local label=self:_keyLabel(k);local tw=measure(label,C.keyFont*s,"Verdana")
    local w=min(C.keyMax*s,max(C.keyMin*s,tw+C.keyPad*2*s));local h=C.keyH*s
    local x=p.x+p.w-C.padR*s-w;local y=cy-h*.5
    local hov=self:_hit(x,y,w,h)
    self:_fill("control",x,y,w,h,hov and"controlHover"or"control",C.keyR*s)
    if self.captureBind==k then self:_out(x,y,w,h,C.keyR*s,1,self:_color("accent"),255) end
    textC(label,x+(w-tw)*.5,cy,self.captureBind==k and self:_color("accent")or self:_color("text"),C.keyFont*s,"Verdana")
    local dx=x-C.dotsGap*s-C.dots*s*.5;local dhs=C.dots*2*s
    self:_icon("dots",dx,cy,C.dots*s,(self.keyMenu and self.keyMenu.control==k)and"text"or"muted")
    local dhx,dhy=dx-C.dots*s,cy-C.dots*s
    if Input.click and not self._consumed then
        if self:_hit(x,y,w,h) then self.captureBind=k;self._captureFrame=E.paintCount;self.inputEdit=nil;self:_consume()
        elseif self:_hit(dhx,dhy,dhs,dhs) then self.keyMenu={control=k,x=x,y=y+h+6*s,w=max(170*s,w),h=5*C.itemH*s};self:_consume() end
    end
end

-- Original Fawn text-field behavior: keep the caret visible by scrolling the text window around it.
function Window:_visibleInputText(c,fw,F)
    local raw=tostring(c.value or"")
    local masked=c.password and string.rep("*",#raw)or raw
    local ed=self.inputEdit and self.inputEdit.control==c and self.inputEdit or nil
    local cursor=ed and clamp(ed.cursor or#raw,0,#raw)or#raw
    local maxW=max(8,fw-(F.ddPadL+F.ddPadR)*self.scale)
    local start=1
    while start<=cursor and measure(sub(masked,start),F.ddFont*self.scale,"Verdana")>maxW do start=start+1 end
    local shown=sub(masked,start)
    while #shown>0 and measure(shown,F.ddFont*self.scale,"Verdana")>maxW do shown=sub(shown,1,-2)end
    local caret=ed and measure(sub(masked,start,cursor),F.ddFont*self.scale,"Verdana")or 0
    return shown,caret,start
end
function Window:_drawFawnInput(c,r,right,cy,F,interactive)
    local s=self.scale;local left=r.x+F.padL*s;local fw=min(F.ctrlW*s,max(64*s,(right-left)*.56));local fh=F.ddH*s;local x=right-fw;local y=cy-fh*.5
    local focused=self.inputEdit and self.inputEdit.control==c;local hov=self:_hit(x,y,fw,fh)
    self:_fill("control",x,y,fw,fh,(focused or hov)and"controlHover"or"control",F.ddR*s)
    if focused then self:_out(x,y,fw,fh,F.ddR*s,1,self:_color("accent"),255)end
    c._inputRect={x,y,fw,fh}
    local shown,caret=self:_visibleInputText(c,fw,F)
    local raw=tostring(c.value or"")
    local col=self:_color("text")
    if shown=="" and raw=="" and not focused then shown=tostring(c.placeholder or"");col=self:_color("muted")end
    local textX=floor(x+F.ddPadL*s)
    textC(shown,textX,cy,col,F.ddFont*s,"Verdana")
    if focused and (nowMs()-(self.inputEdit.blink or 0))%900<450 then
        local cx=clamp(textX+floor(caret+.5),textX-1,floor(x+fw-F.ddPadR*s))
        caretLine(cx,cy,shown,F.ddFont*s,"Verdana",self:_color("accent"),255)
    end
    if interactive and Input.click and not self._consumed and not self:_hasPopup() and hov then
        if not focused then self:_focusInput(c)end
        local ed=self.inputEdit
        if ed and ed.control==c then
            local _,_,start=self:_visibleInputText(c,fw,F)
            local rawv=tostring(c.value or"")
            local masked=c.password and string.rep("*",#rawv)or rawv
            local localX=clamp(Input.mx-textX,0,max(0,fw-(F.ddPadL+F.ddPadR)*s))
            local best=max(0,start-1)
            local bestDist=abs(localX)
            for p=max(0,start-1),#masked do
                local w=measure(sub(masked,start,p),renderedFontSize(F.ddFont*s),"Verdana")
                local d=abs(localX-w)
                if d<=bestDist then best,bestDist=p,d else break end
            end
            ed.cursor=clamp(best,0,#rawv)
            ed.blink=nowMs()
        end
        self:_consume()
    end
end
local _processInputEdit92=Window._processInputEdit
function Window:_processInputEdit()
    local ed=self.inputEdit
    if ed and Input.click and not ed.mouseLatch then
        local c=ed.control;local r=c and c._inputRect
        if r and not self:_hit(r[1],r[2],r[3],r[4]) then self.inputEdit=nil return end
    end
    return _processInputEdit92(self)
end
local _toggleByKey92=Window._toggleByKey
function Window:_toggleByKey()
    if self.inputEdit or self.sliderEdit then return end
    return _toggleByKey92(self)
end

-- Fawn HSV/SV color picker with transparency and copy/paste context menu.
local function rgbToHsv92(r,g,b)
    r,g,b=(r or 0)/255,(g or 0)/255,(b or 0)/255
    local mx,mn=max(r,g,b),min(r,g,b);local d=mx-mn;local h=0
    if d>0 then if mx==r then h=((g-b)/d)%6 elseif mx==g then h=(b-r)/d+2 else h=(r-g)/d+4 end;h=h/6 end
    local s=mx==0 and 0 or d/mx
    return h,s,mx
end
local function hsvToRgb92(h,s,v)
    h=(h%1)*6;local i=floor(h);local f=h-i;local p=v*(1-s);local q=v*(1-f*s);local t=v*(1-(1-f)*s)
    local r,g,b
    if i==0 then r,g,b=v,t,p elseif i==1 then r,g,b=q,v,p elseif i==2 then r,g,b=p,v,t elseif i==3 then r,g,b=p,q,v elseif i==4 then r,g,b=t,p,v else r,g,b=v,p,q end
    return round(r*255),round(g*255),round(b*255)
end
function Window:_drawColorChip(c,right,cy,F,interactive)
    local s=self.scale;local sz=F.sw*s;local x=right-sz;local y=cy-sz*.5
    -- checkerboard makes alpha visible without changing the Fawn chip geometry.
    local tile=max(3,5*s)
    for yy=0,1 do for xx=0,1 do rect(x+xx*sz*.5,y+yy*sz*.5,sz*.5+1,sz*.5+1,((xx+yy)%2==0)and{71,72,78,255}or{35,36,41,255},F.swR*s,255)end end
    rect(x+1*s,y+1*s,sz-2*s,sz-2*s,c.value,max(1,F.swR*s-1*s),c.value[4]or 255)
    outline(x,y,sz,sz,self:_color("outline"),F.swR*s,150,max(1,s))
    if interactive and not self._consumed then
        if Input.click and not self:_hasPopup() and self:_hit(x,y,sz,sz) then
            self.colorPopup={control=c,x=x+sz-278*s,y=y+sz+8*s,w=278*s,h=286*s};self:_consume()
        elseif Input.rightClick and not self:_hasPopup() and self:_hit(x,y,sz,sz) then
            self.colorMenu={control=c,x=Input.mx,y=Input.my,w=168*s,h=94*s};self:_consume()
        end
    end
    return x,y,sz,sz
end
function Window:_drawColorPopup()
    local p=self.colorPopup;if not p then return end
    local c=p.control;if not alive(c)then self.colorPopup=nil return end
    local s=self.scale;p.w=278*s;p.h=286*s;p.anchorY=p.y-8*s;self:_clampPopup(p);self:_popupFrame(p)
    local arr=c.value;local hue,sat,val=rgbToHsv92(arr[1],arr[2],arr[3])
    local svx,svy,svw,svh=p.x+14*s,p.y+52*s,202*s,138*s
    local hx,hy,hw,hh=p.x+228*s,p.y+52*s,22*s,138*s
    local ax,ay,aw,ah=p.x+14*s,p.y+218*s,236*s,16*s
    textC(upper(c.label or"COLOR"),p.x+14*s,p.y+21*s,self:_color("text"),15*s,"Verdana")
    local cols,rows=48,34;local cw,ch=svw/cols,svh/rows
    for iy=0,rows-1 do local vv=1-iy/(rows-1);for ix=0,cols-1 do local ss=ix/(cols-1);local r,g,b=hsvToRgb92(hue,ss,vv);rect(svx+ix*cw,svy+iy*ch,cw+1.1,ch+1.1,{r,g,b,255},0,255)end end
    outline(svx-1,svy-1,svw+2,svh+2,self:_color("outline"),6*s,170,max(1,s))
    local sx=svx+sat*svw;local sy=svy+(1-val)*svh;circle(sx,sy,4*s,self:_color("white"),255);outline(sx-5*s,sy-5*s,10*s,10*s,self:_color("black"),5*s,180,max(1,s))
    for i=0,69 do local r,g,b=hsvToRgb92(i/69,1,1);rect(hx,hy+i*(hh/70),hw,hh/70+1,{r,g,b,255},0,255)end
    outline(hx-1,hy-1,hw+2,hh+2,self:_color("outline"),5*s,170,max(1,s));rect(hx-2*s,hy+hue*hh-1*s,hw+4*s,2*s,self:_color("white"),1*s,255)
    textC("TRANSPARENCY",ax,ay-10*s,self:_color("muted"),12*s,"Verdana")
    local tile=6*s
    for yy=0,2 do for xx=0,ceil(aw/tile)-1 do rect(ax+xx*tile,ay+yy*tile,tile+1,tile+1,((xx+yy)%2==0)and{72,70,78,255}or{39,38,44,255},0,255)end end
    for xx=0,max(1,floor(aw))-1 do local aa=round(xx/max(1,floor(aw)-1)*255);rect(ax+xx,ay,1,ah,{arr[1],arr[2],arr[3],255},0,aa)end
    outline(ax,ay,aw,ah,self:_color("outline"),6*s,170,max(1,s));local alphaX=ax+(arr[4]or 255)/255*aw;rect(alphaX-1*s,ay-1*s,2*s,ah+2*s,self:_color("white"),1*s,255)
    local hex=format("#%02X%02X%02X",arr[1],arr[2],arr[3]);local ap=round((arr[4]or 255)/255*100)
    self:_fill("control",p.x+14*s,p.y+248*s,112*s,25*s,"control",6*s);self:_fill("control",p.x+138*s,p.y+248*s,112*s,25*s,"control",6*s)
    local hw1=measure(hex,13*s,"Verdana");textC(hex,p.x+70*s-hw1*.5,p.y+260*s,self:_color("text"),13*s,"Verdana")
    local at="Alpha "..ap.."%";local aw1=measure(at,13*s,"Verdana");textC(at,p.x+194*s-aw1*.5,p.y+260*s,self:_color("muted"),13*s,"Verdana")
    if Input.click and not self._consumed then
        if self:_hit(svx,svy,svw,svh)then p.drag="sv";self:_consume()
        elseif self:_hit(hx,hy,hw,hh)then p.drag="h";self:_consume()
        elseif self:_hit(ax,ay,aw,ah)then p.drag="a";self:_consume()end
    end
    if p.drag then
        if Input.left then local h0,s0,v0=rgbToHsv92(arr[1],arr[2],arr[3]);local q=copy(arr)
            if p.drag=="sv"then s0=clamp((Input.mx-svx)/svw,0,1);v0=1-clamp((Input.my-svy)/svh,0,1);q[1],q[2],q[3]=hsvToRgb92(h0,s0,v0)
            elseif p.drag=="h"then h0=clamp((Input.my-hy)/hh,0,1);q[1],q[2],q[3]=hsvToRgb92(h0,s0,v0)
            else q[4]=round(clamp((Input.mx-ax)/aw,0,1)*255)end;c:Set(q)
        else p.drag=nil end
    end
end
function Window:_drawColorMenu()
    local p=self.colorMenu;if not p then return end
    local c=p.control;if not alive(c)then self.colorMenu=nil return end
    local s=self.scale;p.w=168*s;p.h=94*s;self:_clampPopup(p);self:_popupFrame(p)
    textC("COLOR",p.x+12*s,p.y+17*s,self:_color("muted"),12*s,"Verdana")
    local rows={{"Copy Color",false},{"Paste Color",true}}
    for i,row in ipairs(rows)do local y=p.y+(32+(i-1)*28)*s;local hov=self:_hit(p.x+6*s,y,p.w-12*s,26*s);if hov then self:_fill("control",p.x+6*s,y,p.w-12*s,26*s,"controlHover",5*s)end
        local disabled=row[2] and not E.colorClipboard;textC(row[1],p.x+14*s,y+13*s,self:_color(disabled and"muted"or"text"),13*s,"Verdana")
        if Input.click and not self._consumed and hov and not disabled then if i==1 then E.colorClipboard=copy(c.value)else c:Set(copy(E.colorClipboard))end;self.colorMenu=nil;self:_consume()end
    end
end

-- Container/page geometry rewritten so resizing cannot leak children or fight scroll ownership.
local function sectionInternalScroll92(sec,contentH,cardH)
    if sec.sizeMode=="fixed" or sec.sizeMode=="fill" then return max(0,contentH-cardH)end
    if sec.maxHeight and contentH>cardH+1 then return max(0,contentH-cardH)end
    return 0
end
function Window:_buildLayout(tab)
    local s=self.scale;local panel=self.kind=="Panel"or self.tabBarVisible==false
    local bodyX=panel and(self.x+18*s)or self:_sx(REF.ContentX)
    local bodyY=panel and(self.y+72*s)or self:_sy(REF.ContentTop)
    local fullBodyW=max(1,panel and((self.width-36)*s)or((self.width-REF.ContentX-REF.RightMargin)*s))
    local fullBodyH=max(1,panel and((self.height-90)*s)or((self.height-REF.ContentTop-15)*s))
    local bodyW,bodyH=fullBodyW,fullBodyH;local preview=nil
    local cols=clamp(self.columns,1,4);local gap=REF.ColumnGap*s
    if tab and alive(tab.dockedPreview) and tab.dockedPreview.visible~=false and tab.dockedPreview.docked~=false then
        local dp=tab.dockedPreview;local pgap=(dp.dockGap or REF.ColumnGap)*s;local desired=clamp(fullBodyW*(dp.dockWidthRatio or .36),220*s,440*s)
        local minContent=max(260*s,cols*235*s+gap*(cols-1))
        local mode=dp.dockMode or"auto"
        local sideOK=(fullBodyW-desired-pgap)>=minContent
        if mode=="side" or(mode=="auto"and sideOK)then
            local pw=min(desired,max(180*s,fullBodyW-minContent-pgap));bodyW=max(1,fullBodyW-pw-pgap);preview={x=bodyX+bodyW+pgap,y=bodyY,w=pw,h=fullBodyH,mode="side"}
        else
            local ph=clamp(fullBodyH*(dp.dockHeightRatio or .38),190*s,340*s);bodyH=max(120*s,fullBodyH-ph-pgap);preview={x=bodyX,y=bodyY+bodyH+pgap,w=fullBodyW,h=min(ph,fullBodyH-bodyH-pgap),mode="bottom"}
        end
    end
    local colW=max(40*s,(bodyW-gap*(cols-1))/cols)
    local sections,rowsMap={},{}
    for _,sec in ipairs(tab.sections)do if alive(sec)and visibilityPass(sec)then local row=max(1,floor(sec.row or 1));rowsMap[row]=rowsMap[row]or{};rowsMap[row][#rowsMap[row]+1]=sec end end
    local rowNums={}for r in pairs(rowsMap)do rowNums[#rowNums+1]=r end;sort(rowNums)
    local y=bodyY-(tab.pageScroll or 0);local contentBottom=bodyY
    for _,row in ipairs(rowNums)do
        local rowSecs=rowsMap[row];local rowH=0;local pre={}
        for _,sec in ipairs(rowSecs)do
            local col=clamp(floor(sec.column or 1),1,cols);local span=clamp(floor(sec.span or 1),1,cols-col+1);local x=bodyX+(col-1)*(colW+gap);local w=max(40*s,colW*span+gap*(span-1))
            local layouts,contentH=self:_sectionControlLayout(sec,x,y+30*s,w);local total
            if sec.sizeMode=="fixed"then total=max(30*s+63*s,(tonumber(sec.height)or 240)*s)
            elseif sec.sizeMode=="fill"then total=max(30*s+63*s,bodyY+bodyH-y)
            else total=30*s+contentH end
            if sec.minHeight then total=max(total,sec.minHeight*s)end;if sec.maxHeight then total=min(total,sec.maxHeight*s)end
            pre[#pre+1]={sec=sec,x=x,w=w,layouts=layouts,contentH=contentH,total=total};rowH=max(rowH,total)
        end
        for _,p in ipairs(pre)do local sec=p.sec;local total=p.total;if sec.sizeMode=="fill"then total=rowH end;local cardY=y+30*s;local cardH=max(1,total-30*s)
            sec.maxScroll=sectionInternalScroll92(sec,p.contentH,cardH);sec.scrollTarget=clamp(sec.scrollTarget or 0,0,sec.maxScroll)
            if self.resizing or self.smoothScroll==false then sec.scroll=sec.scrollTarget else sec.scroll=(sec.scroll or 0)+(sec.scrollTarget-(sec.scroll or 0))*min(1,dt()*self.scrollSpeed)end
            sec.scroll=clamp(sec.scroll or 0,0,sec.maxScroll);sec.resolvedHeight=total/s
            sections[#sections+1]={section=sec,x=p.x,y=y,w=p.w,h=total,cardY=cardY,cardH=cardH,layouts=p.layouts,contentH=p.contentH};contentBottom=max(contentBottom,y+total)
        end
        y=y+rowH+REF.SectionGap*s;contentBottom=max(contentBottom,y)
    end
    local contentH=max(0,contentBottom-bodyY-(#rowNums>0 and REF.SectionGap*s or 0));tab.maxScroll=max(0,contentH-bodyH)
    if self.mainScrollEnabled~=false and tab.mainScrollEnabled~=false then tab.pageTarget=clamp(tab.pageTarget or 0,0,tab.maxScroll)else tab.pageTarget=0 end
    if self.resizing or self.smoothScroll==false then tab.pageScroll=tab.pageTarget else tab.pageScroll=(tab.pageScroll or 0)+(tab.pageTarget-(tab.pageScroll or 0))*min(1,dt()*self.scrollSpeed)end
    tab.pageScroll=clamp(tab.pageScroll or 0,0,tab.maxScroll)
    self._layout={bodyX=bodyX,bodyY=bodyY,bodyW=bodyW,fullBodyW=fullBodyW,bodyH=bodyH,fullBodyH=fullBodyH,sections=sections,contentH=contentH,maxScroll=tab.maxScroll,preview=preview}
    return self._layout
end
function Window:_drawSection(box,bodyTop,bodyBottom,bodyLeft,bodyRight)
    local sec=box.section;local s=self.scale;local titleY=box.y+7*s
    local clipL=max(bodyLeft or box.x,box.x);local clipR=min(bodyRight or(box.x+box.w),box.x+box.w)
    local cardTop=box.cardY;local cardBottom=cardTop+box.cardH;local clipT=max(bodyTop,cardTop);local clipB=min(bodyBottom,cardBottom)
    if titleY>=bodyTop-20*s and titleY<=bodyBottom and box.x>=bodyLeft-1 and box.x<=(bodyRight or box.x+box.w)then textC(fit(upper(sec.name),max(20,box.w-44*s),14*s,"Verdana"),box.x+22*s,titleY,self:_color("muted"),14*s,"Verdana")end
    if clipB<=clipT or clipR<=clipL then return end
    -- card background is explicitly intersected with the body viewport.
    self:_fill("card",clipL,clipT,clipR-clipL,clipB-clipT,"card",0)
    local rows={}for c,r in pairs(box.layouts)do rows[#rows+1]={c=c,r=r}end;sort(rows,function(a,b)if a.r.y==b.r.y then return a.r.x<b.r.x end return a.r.y<b.r.y end)
    local offset=sec.scroll or 0
    for _,q in ipairs(rows)do local r={x=q.r.x,y=q.r.y-offset,w=q.r.w,h=q.r.h};if r.x+r.w>clipL and r.x<clipR then self:_drawControl(q.c,r,clipT,clipB)end end
    -- redraw a clean outline only when the complete card edge is inside the viewport.
    if cardTop>=bodyTop and cardBottom<=bodyBottom and box.x>=bodyLeft and box.x+box.w<=bodyRight then self:_out(box.x,cardTop,box.w,box.cardH,14*s,.8,self:_color("outline"),100)end
    if sec.maxScroll>1 then local trackX=min(box.x+box.w-7*s,bodyRight-5*s);local top=clipT+7*s;local bh=clipB-top-7*s
        if bh>20*s then local thumb=max(28*s,bh*(box.cardH/max(box.cardH,box.contentH)));local span=max(1,bh-thumb);local ratio=(sec.scroll or 0)/sec.maxScroll;local ty=top+span*ratio
            rect(trackX,top,2*s,bh,self:_color("control"),1*s,140);rect(trackX-1*s,ty,4*s,thumb,self:_color("outline"),2*s,220)
            if Input.click and not self._consumed and not self:_hasPopup()and self:_hit(trackX-6*s,ty-3*s,14*s,thumb+6*s)then sec._scrollDrag={top=top,span=span,off=Input.my-ty};self:_consume()end
            if sec._scrollDrag then if Input.left then sec.scrollTarget=clamp((Input.my-sec._scrollDrag.top-sec._scrollDrag.off)/sec._scrollDrag.span,0,1)*sec.maxScroll;sec.scroll=sec.scrollTarget else sec._scrollDrag=nil end end
        end
    else sec._scrollDrag=nil end
end
function Window:_drawContent()
    local s=self.scale;local tab=self:_activeTab();if not tab then return end;local layout=self:_buildLayout(tab);local top,bottom=layout.bodyY,layout.bodyY+layout.bodyH;local left,right=layout.bodyX,layout.bodyX+layout.bodyW
    local pointerBody=self:_hit(left,top,layout.bodyW,layout.bodyH);local wheelOwned=false
    for _,box in ipairs(layout.sections)do local sec=box.section;local ht=max(box.cardY,top);local hb=min(box.cardY+box.cardH,bottom)
        if sec.maxScroll>1 and hb>ht and self:_hit(max(box.x,left),ht,min(box.x+box.w,right)-max(box.x,left),hb-ht)and Input.wheel~=0 and not self:_hasPopup()then sec:ScrollBy(Input.wheel*sec:GetScrollStep());wheelOwned=true;break end
    end
    if not wheelOwned and pointerBody and Input.wheel~=0 and not self:_hasPopup()and tab.maxScroll>0 then tab:ScrollBy(Input.wheel*tab:GetScrollStep())end
    for _,box in ipairs(layout.sections)do if box.y+box.h>=top and box.y<=bottom and box.x+box.w>=left and box.x<=right then self:_drawSection(box,top,bottom,left,right)end end
    if layout.preview and alive(tab.dockedPreview)then tab.dockedPreview:_renderDocked(layout.preview)end
    if #layout.sections==0 then local h=min(220*s,layout.bodyH);self:_fill("card",left,top,layout.bodyW,h,"card",14*s);self:_out(left,top,layout.bodyW,h,14*s,.8,self:_color("outline"),100);local msg="No settings on this tab yet";local tw,th=measure(msg,18*s,"Verdana");text(msg,left+(layout.bodyW-tw)*.5,top+(h-th)*.5,self:_color("muted"),18*s,"Verdana")end
    if tab.maxScroll>1 then local tx=right-5*s;local th=max(20*s,layout.bodyH-8*s);local ty=top+4*s;local thumb=max(32*s,th*(layout.bodyH/max(layout.bodyH,layout.contentH)));local span=max(1,th-thumb);local rr=(tab.pageScroll or 0)/tab.maxScroll;local yy=ty+span*rr
        rect(tx,ty,2*s,th,self:_color("control"),1*s,140);rect(tx-1*s,yy,4*s,thumb,self:_color("outline"),2*s,230)
        if Input.click and not self._consumed and not self:_hasPopup()and self:_hit(tx-6*s,yy-3*s,14*s,thumb+6*s)then tab._pageDrag={top=ty,span=span,off=Input.my-yy};self:_consume()end
        if tab._pageDrag then if Input.left then tab.pageTarget=clamp((Input.my-tab._pageDrag.top-tab._pageDrag.off)/tab._pageDrag.span,0,1)*tab.maxScroll;tab.pageScroll=tab.pageTarget else tab._pageDrag=nil end end
    else tab._pageDrag=nil end
end

-- Pixel-stable resize anchors; logical window size is derived from the frozen screen-space edges.
function Window:_updateWindowDragResize()
    local s=self.scale;local X,Y=self.x,self.y;local W,H=self.width*s,self.height*s;local edge=max(6,7*s)
    if self.resizing then
        if self.resizable==false or not Input.left then self.resizing=nil return end
        local r=self.resizing;local dx=Input.mx-r.mx;local dy=Input.my-r.my;local L,R,T,B=r.L,r.R,r.T,r.B
        if r.l then L=r.L+dx end;if r.r then R=r.R+dx end;if r.t then T=r.T+dy end;if r.b then B=r.B+dy end
        local minW,maxW=self.minWidth*s,self.maxWidth*s;local minH,maxH=self.minHeight*s,self.maxHeight*s
        local ww=R-L;if ww<minW then if r.l and not r.r then L=R-minW else R=L+minW end elseif ww>maxW then if r.l and not r.r then L=R-maxW else R=L+maxW end end
        local hh=B-T;if hh<minH then if r.t and not r.b then T=B-minH else B=T+minH end elseif hh>maxH then if r.t and not r.b then T=B-maxH else B=T+maxH end end
        self.x=floor(L+.5);self.y=floor(T+.5);self.width=(R-L)/s;self.height=(B-T)/s;return
    end
    if self.dragging then if self.draggable==false then self.dragging=nil return end;if Input.left then self.x=floor(Input.mx-self.dragging.ox+.5);self.y=floor(Input.my-self.dragging.oy+.5)else self.dragging=nil end;return end
    if not Input.click or self._consumed or self:_hasPopup()then return end
    local l=self:_hit(X-edge,Y,edge*2,H);local r=self:_hit(X+W-edge,Y,edge*2,H);local t=self:_hit(X,Y-edge,W,edge*2);local b=self:_hit(X,Y+H-edge,W,edge*2)
    if self.resizable~=false and(l or r or t or b)then self.resizing={mx=Input.mx,my=Input.my,L=X,R=X+W,T=Y,B=Y+H,l=l,r=r,t=t,b=b};self:_closePopups();self:_consume();return end
    local headerHit=(self.kind=="Panel"or self.tabBarVisible==false)and self:_hit(X,Y,W,64*s)or self:_hit(X,Y,REF.Sidebar*s,90*s)
    if self.draggable~=false and headerHit then self.dragging={ox=Input.mx-X,oy=Input.my-Y};self:_closePopups();self:_consume()end
end

-- ESP widget editor: seamless dock mode, 8-slot moving, order/shuffle tools.
local ESP_SLOT_MAP={top=2,bottom=8,left=4,right=6,["top-left"]=1,["top-right"]=3,["bottom-left"]=7,["bottom-right"]=9}
local function espSlot92(v)if type(v)=="number"then local n=clamp(floor(v),1,9);return n==5 and 2 or n end;return ESP_SLOT_MAP[lower(tostring(v or""))]or 2 end
local function slotInfo92(slot,bx,by,bw,bh,gap)
    gap=gap or 12;local row=floor((slot-1)/3)+1;local col=((slot-1)%3)+1;local x=col==1 and(bx-gap)or(col==2 and(bx+bw*.5)or(bx+bw+gap));local y=row==1 and(by-gap)or(row==2 and(by+bh*.5)or(by+bh+gap));return x,y,row,col
end
local function nearestSlot92(x,y,bx,by,bw,bh,health)
    local best,bestD=2,1e30;for _,slot in ipairs(health and{2,4,6,8}or{1,2,3,4,6,7,8,9})do local ax,ay=slotInfo92(slot,bx,by,bw,bh,12);local dx,dy=x-ax,y-ay;local d=dx*dx+dy*dy;if d<bestD then best,bestD=slot,d end end;return best
end
function ESPPreview:SetElementPosition(name,slot)name=lower(tostring(name or""));self.positions[name]=espSlot92(slot);return self end
function ESPPreview:ResetLayout()self.positions={name=2,healthbar=4,healthtext=6,distance=8};self.order={name=1,healthtext=2,distance=3};return self end
function ESPPreview:SetSeamless(v)self.seamless=v~=false;return self end
function ESPPreview:GetSeamless()return self.seamless~=false end
function ESPPreview:SetDockMode(v)v=lower(tostring(v or"auto"));if v~="auto"and v~="side"and v~="bottom"then v="auto"end;self.dockMode=v;return self end
function ESPPreview:SetWidgetTools(v)self.widgetTools=v~=false;return self end
function ESPPreview:GetWidgetTools()return self.widgetTools~=false end
function ESPPreview:GetWidgetOrder()return copy(self.order or{})end
function ESPPreview:SetWidgetOrder(t)if type(t)=="table"then self.order=copy(t)end;return self end
function ESPPreview:ShuffleWidgets()
    local slots={1,2,3,4,6,7,8,9};for i=#slots,2,-1 do local j=math.random and math.random(i)or((i*7)%i+1);slots[i],slots[j]=slots[j],slots[i]end
    local n=1;for _,k in ipairs{"name","healthtext","distance"}do self.positions[k]=slots[n];n=n+1 end;self.positions.healthbar=({2,4,6,8})[(math.random and math.random(4))or 2];return self
end
local function espReorder92(self,kind,slot,mouseY,bx,by,bw,bh)
    if kind=="healthbar"then return end;self.order=self.order or{name=1,healthtext=2,distance=3};local list={};for _,k in ipairs{"name","healthtext","distance"}do if k~=kind and self.positions[k]==slot then list[#list+1]=k end end;sort(list,function(a,b)return(self.order[a]or 99)<(self.order[b]or 99)end)
    local _,ay,row=slotInfo92(slot,bx,by,bw,bh,12);local n=#list+1;local lineH=20;local startY=row==1 and(ay-8-n*lineH)or(row==2 and(ay-n*lineH*.5)or(ay+8));local ins=n;for i=1,n do if mouseY<startY+(i-.5)*lineH then ins=i break end end;local merged={};local oi=1;for i=1,n do if i==ins then merged[#merged+1]=kind else merged[#merged+1]=list[oi];oi=oi+1 end end;for i,k in ipairs(merged)do self.order[k]=i end
end
function ESPPreview:_drawBody(x,y,w,h,docked)
    self:_syncBindings();local win=self.window;local s=win and win.scale or 1;self.order=self.order or{name=1,healthtext=2,distance=3}
    local seamless=docked and self.seamless~=false;local titleH=seamless and 30*s or 42*s;local pad=15*s
    if seamless then textC(upper(self.title or"ESP PREVIEW"),x+22*s,y+7*s,self:_theme("muted"),14*s,"Verdana")
        local cardY=y+30*s;local cardH=max(1,h-30*s);rect(x,cardY,w,cardH,glassColor(win,"card",self:_theme("card")),14*s,alphaFor(win,"card",255));outline(x,cardY,w,cardH,(win and win.outlineColor)or self:_theme("outline"),14*s,110,max(.8,s*((win and win.outlineStrength)or 1)))
        y=cardY;h=cardH;titleH=0
    else local frame=glassColor(win,"card",self:_theme("card"));rect(x,y,w,h,frame,14*s,alphaFor(win,"card",frame[4]or 255));outline(x,y,w,h,(win and win.outlineColor)or self:_theme("outline"),14*s,130,max(.8,s*((win and win.outlineStrength)or 1)));textC(upper(self.title or"ESP PREVIEW"),x+pad,y+21*s,self:_theme("muted"),13*s,"Verdana");line(x,y+42*s,x+w,y+42*s,self:_theme("line"),1,32)end
    local stageX=x+pad;local stageY=y+titleH+pad;local stageW=max(40,w-pad*2);local stageH=max(60,h-titleH-pad*2)
    local stage=glassColor(win,"control",self:_theme("control"));rect(stageX,stageY,stageW,stageH,stage,12*s,alphaFor(win,"control",stage[4]or 255));outline(stageX,stageY,stageW,stageH,self:_theme("outline"),12*s,70,max(1,s))
    if self.editable and self.widgetTools~=false then
        local bw,bh,g=58*s,23*s,6*s;local rx,ry=stageX+stageW-2*bw-g-8*s,stageY+8*s
        local function tool(xx,label,fn)local hov=self:_hitESP(Input.mx,Input.my,xx,ry,bw,bh);rect(xx,ry,bw,bh,hov and self:_theme("controlHover")or self:_theme("control"),6*s,230);local tw=measure(label,10*s,"Verdana");textC(label,xx+(bw-tw)*.5,ry+bh*.5,self:_theme("text"),10*s,"Verdana");if Input.click and hov then fn()end end
        tool(rx,"RESET",function()self:ResetLayout()end);tool(rx+bw+g,"SHUFFLE",function()self:ShuffleWidgets()end)
    end
    local humanW=min(stageW*.42,180*s);local humanH=min(stageH*.60,330*s);local bx=stageX+(stageW-humanW)*.5;local by=stageY+(stageH-humanH)*.52
    local boxCol=self.colors.box or self:_theme("white");if self.features.boxes~=false then outline(bx,by,humanW,humanH,boxCol,0,boxCol[4]or 255,(self.boxThickness or 1)*s)end
    if self.features.skeleton then local sk=self.colors.skeleton or self:_theme("white");local cx=bx+humanW*.5;local hy=by+humanH*.15;circle(cx,hy,humanW*.08,sk,255);line(cx,hy+humanW*.08,cx,by+humanH*.55,sk,1*s);line(cx,by+humanH*.3,bx+humanW*.22,by+humanH*.48,sk,1*s);line(cx,by+humanH*.3,bx+humanW*.78,by+humanH*.48,sk,1*s);line(cx,by+humanH*.55,bx+humanW*.3,by+humanH*.9,sk,1*s);line(cx,by+humanH*.55,bx+humanW*.7,by+humanH*.9,sk,1*s)end
    local health=self:_currentHealth();local hpCol=self.colors.health or{92,213,117,255};self.positions.healthbar=espSlot92(self.positions.healthbar or 4)
    local hits={};local function hit(kind,xx,yy,ww,hh)hits[#hits+1]={kind=kind,x=xx,y=yy,w=ww,h=hh}end
    if self.features.healthbar~=false and(self.healthStyle=="bar"or self.healthStyle=="both"or self.healthStyle==nil)then local slot=self.positions.healthbar;local side=(slot==2 or slot==4 or slot==6 or slot==8)and slot or 4;local ax,ay=slotInfo92(side,bx,by,humanW,humanH,12*s)
        if side==4 or side==6 then local hx=side==4 and bx-11*s or bx+humanW+7*s;rect(hx,by,5*s,humanH,{12,13,17,255},2*s,220);local fh=humanH*health/100;rect(hx,by+humanH-fh,5*s,fh,hpCol,2*s,hpCol[4]or 255);hit("healthbar",hx-8*s,by-5*s,21*s,humanH+10*s)
        else local hy=side==2 and by-11*s or by+humanH+7*s;rect(bx,hy,humanW,5*s,{12,13,17,255},2*s,220);rect(bx,hy,humanW*health/100,5*s,hpCol,2*s,hpCol[4]or 255);hit("healthbar",bx-5*s,hy-8*s,humanW+10*s,21*s)end
    end
    local groups={};local function add(kind,textv,col)if not self.features[kind]then return end;local slot=espSlot92(self.positions[kind]or(kind=="distance"and 8 or(kind=="healthtext"and 6 or 2)));self.positions[kind]=slot;groups[slot]=groups[slot]or{};groups[slot][#groups[slot]+1]={kind=kind,text=textv,col=col}end
    add("name",self.texts.name or"Player",self.colors.name or self:_theme("text"));if self.features.healthtext or self.healthStyle=="text"or self.healthStyle=="both"then self.features.healthtext=true;add("healthtext",tostring(round(health)),hpCol)end;add("distance",self.texts.distance or"42m",self.colors.distance or self:_theme("muted"))
    for slot,list in pairs(groups)do sort(list,function(a,b)return(self.order[a.kind]or 99)<(self.order[b.kind]or 99)end);local ax,ay,row,col=slotInfo92(slot,bx,by,humanW,humanH,12*s);local lineH=18*s;local maxW=0;for _,it in ipairs(list)do maxW=max(maxW,measure(it.text,13*s,"Verdana"))end;local total=#list*lineH;local sx=col==1 and(ax-8*s-maxW)or(col==2 and(ax-maxW*.5)or ax+8*s);local sy=row==1 and(ay-8*s-total)or(row==2 and(ay-total*.5)or ay+8*s);for i,it in ipairs(list)do local tw=measure(it.text,13*s,"Verdana");local tx=col==1 and(sx+maxW-tw)or(col==2 and(sx+(maxW-tw)*.5)or sx);local ty=sy+(i-1)*lineH;text(it.text,tx,ty,it.col,13*s,"Verdana");hit(it.kind,tx-4*s,ty-3*s,tw+8*s,18*s)end end
    if self.features.snapline then line(stageX+stageW*.5,stageY+stageH,bx+humanW*.5,by+humanH,self.colors.snapline or self:_theme("accent"),1*s,200)end
    if self.editable and not self._espDrag and Input.click then for i=#hits,1,-1 do local q=hits[i];if self:_hitESP(Input.mx,Input.my,q.x,q.y,q.w,q.h)then self._espDrag=q.kind;break end end end
    if self._espDrag then local k=self._espDrag;local near=nearestSlot92(Input.mx,Input.my,bx,by,humanW,humanH,k=="healthbar");for _,slot in ipairs(k=="healthbar"and{2,4,6,8}or{1,2,3,4,6,7,8,9})do local ax,ay=slotInfo92(slot,bx,by,humanW,humanH,12*s);local active=slot==near;circle(ax,ay,(active and 4 or 2.5)*s,active and self:_theme("accent")or self:_theme("muted"),active and 255 or 180)end;if not Input.left then espReorder92(self,k,near,Input.my,bx,by,humanW,humanH);self.positions[k]=near;self._espDrag=nil end end
end
local _oldESPFactory92=Window.ESPPreview
function Window:ESPPreview(opt)
    local o=_oldESPFactory92(self,opt);opt=type(opt)=="table"and opt or{};o.positions={name=espSlot92(opt.namePosition or 2),healthbar=espSlot92(opt.healthPosition or 4),healthtext=espSlot92(opt.healthTextPosition or 6),distance=espSlot92(opt.distancePosition or 8)};o.order={name=1,healthtext=2,distance=3};o.seamless=opt.seamless~=false;o.dockMode=opt.dockMode or"auto";o.dockHeightRatio=clamp(tonumber(opt.dockHeightRatio)or .38,.25,.55);o.widgetTools=opt.widgetTools~=false;return o
end
Window.ESPWindow=Window.ESPPreview

-- Render order updated for nested accessory/color popups and robust outside-click handling.
function Window:_render()
    if self.destroyed then return end;self:_toggleByKey();self:_processKeybinds();self:_processBindCapture();self:_processInputEdit();self:_processSliderEdit();if not self.visible then return end
    self._consumed=false;self:_updateWindowDragResize();local s=self.scale;local X,Y=self.x,self.y;local W,H=self.width*s,self.height*s
    if Input.click and not self._consumed and self:_hasPopup()then
        local inside=false;for _,p in pairs({openDrop=self.openDrop,extraPopup=self.extraPopup,keyMenu=self.keyMenu,colorPopup=self.colorPopup,colorMenu=self.colorMenu,configPopup=self.configPopup,groupPopup=self.groupPopup})do if p and p.x and p.y and p.w and p.h and self:_hit(p.x,p.y,p.w,p.h)then inside=true break end end
        if self.accountOpen then local _,py=self:_sidebarGeometry();if self:_hit(X+7*s,py-244*s,261*s,236*s)or self:_hit(X+15*s,py,245*s,55*s)then inside=true end end
        if not inside then self:_closePopups();self:_consume()end
    end
    self:_fill("main",X,Y,W,H,"menuBg",self.corner*s);self:_drawContent()
    -- hard masks guarantee that content never escapes the body even when native draw clipping is unavailable.
    if self.kind=="Panel"or self.tabBarVisible==false then
        self:_fill("main",X,Y,W,72*s,"menuBg",self.corner*s);self:_fill("main",X,Y+H-18*s,W,18*s,"menuBg",0);self:_fill("main",X,Y,18*s,H,"menuBg",0);self:_fill("main",X+W-18*s,Y,18*s,H,"menuBg",0);self:_drawPanelHeader()
    else
        self:_fill("main",X,Y,REF.ContentX*s,H,"menuBg",0);self:_fill("main",X,Y,W,REF.ContentTop*s,"menuBg",0);self:_fill("main",X+W-REF.RightMargin*s,Y,REF.RightMargin*s,H,"menuBg",0);self:_fill("main",X,Y+H-15*s,W,15*s,"menuBg",0);self:_drawSidebar();self:_drawTopbar()
    end
    self:_out(X,Y,W,H,self.corner*s,self.borderThickness,self.outlineColor,255)
    self:_drawDropdownPopup();self:_drawExtraPopup();self:_drawKeyMenu();self:_drawColorPopup();self:_drawColorMenu();self:_drawConfigPopup();self:_drawGroupPopup();self:_drawAccountPopup();self:_drawSearchPopup()
end

Fawn.Runtime.ContainerScrolling="reserved section/page gutters + nested ownership + hover/drag accent feedback"
Fawn.Runtime.Resize="deferred mouse-anchored UI scale + frozen screen-space physical resize"
Fawn.Runtime.ESPWidgets="original Fawn cursor-follow drag parity + 8-slot commit + stacking reorder, reset and shuffle tools"
Fawn.Runtime.ColorPicker="original Fawn HSV/SV + hue + alpha picker with color clipboard"
Fawn.Runtime.Input="original Fawn caret-aware single-line text input with horizontal text window"


-- Compatibility layer: containment / scale / ESP parity.
local function applyScale93(self,newScale)
    local old=self.scale or 1
    newScale=clamp(tonumber(newScale)or old,.55,1.65)
    if abs(newScale-old)<.0001 then self.scale=newScale return self end
    local pxW,pxH=self.width*old,self.height*old
    local ax,ay=self.x+pxW*.5,self.y+pxH*.5
    if Input.left and Input.mx>=self.x and Input.mx<=self.x+pxW and Input.my>=self.y and Input.my<=self.y+pxH then ax,ay=Input.mx,Input.my end
    local lx=(ax-self.x)/old;local ly=(ay-self.y)/old
    self.scale=newScale
    self.x=floor(ax-lx*newScale+.5);self.y=floor(ay-ly*newScale+.5)
    self._layout=nil
    if self.inputEdit then self.inputEdit.blink=nowMs();if self.inputEdit.control then self.inputEdit.control._inputRect=nil end end
    if self.sliderEdit then self.sliderEdit.blink=nowMs();self.sliderEdit.rect=nil end
    for _,t in ipairs(self.tabs or{})do
        t.pageTarget=max(0,t.pageTarget or 0);t.pageScroll=max(0,t.pageScroll or 0)
        for _,sec in ipairs(t.sections or{})do sec.scrollTarget=max(0,sec.scrollTarget or 0);sec.scroll=max(0,sec.scroll or 0)end
    end
    self:_closePopups()
    return self
end
function Window:SetScale(v)
    local nv=clamp(tonumber(v)or self.scale,.55,1.65)
    if self._inRender then self._pendingScale=nv return self end
    return applyScale93(self,nv)
end

local function maskTop93(self,x,y,w,h,r)
    if h<=0 then return end
    self:_fill("main",x,y,w,h,"menuBg",min(r,h*.5))
    local cut=min(r,h)
    if h>cut then self:_fill("main",x,y+cut,w,h-cut,"menuBg",0)end
end
local function maskBottom93(self,x,y,w,h,r)
    if h<=0 then return end
    self:_fill("main",x,y,w,h,"menuBg",min(r,h*.5))
    local cut=min(r,h)
    if h>cut then self:_fill("main",x,y,w,h-cut,"menuBg",0)end
end

function Window:_drawSection(box,bodyTop,bodyBottom,bodyLeft,bodyRight)
    local sec=box.section;local s=self.scale
    local cardTop=box.cardY;local cardBottom=cardTop+box.cardH
    local clipL=max(bodyLeft or box.x,box.x);local clipR=min(bodyRight or(box.x+box.w),box.x+box.w)
    local clipT=max(bodyTop,cardTop);local clipB=min(bodyBottom,cardBottom)
    local fullCard=clipL==box.x and clipR==box.x+box.w and clipT==cardTop and clipB==cardBottom
    if clipB<=clipT or clipR<=clipL then return end
    self:_fill("card",clipL,clipT,clipR-clipL,clipB-clipT,"card",fullCard and 14*s or 0)

    local rows={};for c,r in pairs(box.layouts)do rows[#rows+1]={c=c,r=r}end
    sort(rows,function(a,b)if a.r.y==b.r.y then return a.r.x<b.r.x end return a.r.y<b.r.y end)
    local offset=sec.scroll or 0
    for _,q in ipairs(rows)do
        local r={x=q.r.x,y=q.r.y-offset,w=q.r.w,h=q.r.h}
        -- No text/control is emitted for a partially clipped row. This prevents native text from leaking
        -- through a Section boundary on scroll or during a scale/resize reflow.
        if r.y>=clipT-.25 and r.y+r.h<=clipB+.25 and r.x>=clipL-.25 and r.x+r.w<=clipR+.25 then
            self:_drawControl(q.c,r,clipT,clipB)
        end
    end

    if sec.columnDividers==true and sec.columns and sec.columns>1 and fullCard then
        local gap=(sec.controlGap or 12)*s;local cw=(box.w-gap*(sec.columns-1))/sec.columns
        for i=1,sec.columns-1 do local x=box.x+i*cw+(i-.5)*gap;line(x,cardTop+8*s,x,cardBottom-8*s,self:_color("line"),1,14)end
    end

    if fullCard then self:_out(box.x,cardTop,box.w,box.cardH,14*s,.8,self:_color("outline"),100)end

    if sec.maxScroll>1 then
        local trackX=min(box.x+box.w-7*s,(bodyRight or box.x+box.w)-5*s);local top=clipT+7*s;local bh=clipB-top-7*s
        if bh>20*s then
            local thumb=max(28*s,bh*(box.cardH/max(box.cardH,box.contentH)));local span=max(1,bh-thumb)
            local ratio=(sec.scroll or 0)/sec.maxScroll;local ty=top+span*ratio
            local trackHover=self:_hit(trackX-7*s,top,15*s,bh);local thumbHover=self:_hit(trackX-7*s,ty-3*s,15*s,thumb+6*s);local active=sec._scrollDrag~=nil
            rect(trackX,top,2*s,bh,self:_color(trackHover and"controlHover"or"control"),1*s,trackHover and 190 or 140)
            rect(trackX-((active or thumbHover)and 1.5*s or 1*s),ty,(active or thumbHover)and 5*s or 4*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 220)
            if Input.click and not self._consumed and not self:_hasPopup()and thumbHover then sec._scrollDrag={top=top,span=span,off=Input.my-ty};self:_consume()end
            if sec._scrollDrag then if Input.left then sec.scrollTarget=clamp((Input.my-sec._scrollDrag.top-sec._scrollDrag.off)/sec._scrollDrag.span,0,1)*sec.maxScroll;sec.scroll=sec.scrollTarget else sec._scrollDrag=nil end end
        end
    else sec._scrollDrag=nil end

    -- Title is rendered last so internal content can never paint over the title band.
    local titleY=box.y+7*s
    if titleY>=bodyTop-20*s and titleY<=bodyBottom and box.x>=bodyLeft-1 and box.x<=(bodyRight or box.x+box.w)then
        textC(fit(upper(sec.name),max(20,box.w-44*s),14*s,"Verdana"),box.x+22*s,titleY,self:_color("muted"),14*s,"Verdana")
    end
end

function Window:_drawContent()
    local s=self.scale;local tab=self:_activeTab();if not tab then return end
    local layout=self:_buildLayout(tab);local top,bottom=layout.bodyY,layout.bodyY+layout.bodyH;local left,right=layout.bodyX,layout.bodyX+layout.bodyW
    local pointerBody=self:_hit(left,top,layout.bodyW,layout.bodyH);local wheelOwned=false
    for _,box in ipairs(layout.sections)do
        local sec=box.section;local l=max(box.x,left);local r=min(box.x+box.w,right);local ht=max(box.cardY,top);local hb=min(box.cardY+box.cardH,bottom)
        if sec.maxScroll>1 and r>l and hb>ht and self:_hit(l,ht,r-l,hb-ht)and Input.wheel~=0 and not self:_hasPopup()then sec:ScrollBy(Input.wheel*sec:GetScrollStep());wheelOwned=true;break end
    end
    if not wheelOwned and pointerBody and Input.wheel~=0 and not self:_hasPopup()and tab.maxScroll>0 then tab:ScrollBy(Input.wheel*tab:GetScrollStep())end
    for _,box in ipairs(layout.sections)do if box.y+box.h>=top and box.y<=bottom and box.x+box.w>=left and box.x<=right then self:_drawSection(box,top,bottom,left,right)end end
    if layout.preview and alive(tab.dockedPreview)then tab.dockedPreview:_renderDocked(layout.preview)end
    if #layout.sections==0 then local h=min(220*s,layout.bodyH);self:_fill("card",left,top,layout.bodyW,h,"card",14*s);self:_out(left,top,layout.bodyW,h,14*s,.8,self:_color("outline"),100);local msg="No settings on this tab yet";local tw,th=measure(msg,18*s,"Verdana");text(msg,left+(layout.bodyW-tw)*.5,top+(h-th)*.5,self:_color("muted"),18*s,"Verdana")end
    if tab.maxScroll>1 then
        local tx=right-5*s;local th=max(20*s,layout.bodyH-8*s);local ty=top+4*s;local thumb=max(32*s,th*(layout.bodyH/max(layout.bodyH,layout.contentH)));local span=max(1,th-thumb);local rr=(tab.pageScroll or 0)/tab.maxScroll;local yy=ty+span*rr
        local trackHover=self:_hit(tx-7*s,ty,15*s,th);local thumbHover=self:_hit(tx-7*s,yy-3*s,15*s,thumb+6*s);local active=tab._pageDrag~=nil
        rect(tx,ty,2*s,th,self:_color(trackHover and"controlHover"or"control"),1*s,trackHover and 190 or 140)
        rect(tx-((active or thumbHover)and 1.5*s or 1*s),yy,(active or thumbHover)and 5*s or 4*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 230)
        if Input.click and not self._consumed and not self:_hasPopup()and thumbHover then tab._pageDrag={top=ty,span=span,off=Input.my-yy};self:_consume()end
        if tab._pageDrag then if Input.left then tab.pageTarget=clamp((Input.my-tab._pageDrag.top-tab._pageDrag.off)/tab._pageDrag.span,0,1)*tab.maxScroll;tab.pageScroll=tab.pageTarget else tab._pageDrag=nil end end
    else tab._pageDrag=nil end
end

-- Fawn-original ESP drag parity: the widget follows the cursor during drag and commits into the nearest slot on release.
function ESPPreview:_drawBody(x,y,w,h,docked)
    self:_syncBindings();local win=self.window;local s=win and win.scale or 1;self.order=self.order or{name=1,healthtext=2,distance=3}
    local seamless=docked and self.seamless~=false;local titleH=seamless and 30*s or 42*s;local pad=15*s
    if seamless then
        textC(upper(self.title or"ESP PREVIEW"),x+22*s,y+7*s,self:_theme("muted"),14*s,"Verdana")
        local cardY=y+30*s;local cardH=max(1,h-30*s);rect(x,cardY,w,cardH,glassColor(win,"card",self:_theme("card")),14*s,alphaFor(win,"card",255));outline(x,cardY,w,cardH,(win and win.outlineColor)or self:_theme("outline"),14*s,110,max(.8,s*((win and win.outlineStrength)or 1)));y=cardY;h=cardH;titleH=0
    else
        local frame=glassColor(win,"card",self:_theme("card"));rect(x,y,w,h,frame,14*s,alphaFor(win,"card",frame[4]or 255));outline(x,y,w,h,(win and win.outlineColor)or self:_theme("outline"),14*s,130,max(.8,s*((win and win.outlineStrength)or 1)));textC(upper(self.title or"ESP PREVIEW"),x+pad,y+21*s,self:_theme("muted"),13*s,"Verdana");line(x,y+42*s,x+w,y+42*s,self:_theme("line"),1,32)
    end
    local stageX=x+pad;local stageY=y+titleH+pad;local stageW=max(40,w-pad*2);local stageH=max(60,h-titleH-pad*2)
    local stage=glassColor(win,"control",self:_theme("control"));rect(stageX,stageY,stageW,stageH,stage,12*s,alphaFor(win,"control",stage[4]or 255));outline(stageX,stageY,stageW,stageH,self:_theme("outline"),12*s,70,max(1,s))
    if self.editable and self.widgetTools~=false then
        local bw,bh,g=58*s,23*s,6*s;local rx,ry=stageX+stageW-2*bw-g-8*s,stageY+8*s
        local function tool(xx,label,fn)local hov=Input.mx>=xx and Input.mx<xx+bw and Input.my>=ry and Input.my<ry+bh;rect(xx,ry,bw,bh,hov and self:_theme("controlHover")or self:_theme("card"),6*s,220);outline(xx,ry,bw,bh,self:_theme("outline"),6*s,80,max(1,s));local tw=measure(label,10*s,"Verdana");text(label,xx+(bw-tw)*.5,ry+5*s,self:_theme("text"),10*s,"Verdana");if Input.click and hov and(not win or not win._consumed)then fn();if win then win:_consume()end end end
        tool(rx,"RESET",function()self:ResetLayout()end);tool(rx+bw+g,"SHUFFLE",function()self:ShuffleWidgets()end)
    end
    local humanW=min(stageW*.42,180*s);local humanH=min(stageH*.60,330*s);local bx=stageX+(stageW-humanW)*.5;local by=stageY+(stageH-humanH)*.52
    local boxCol=self.colors.box or self:_theme("white");if self.features.boxes~=false then outline(bx,by,humanW,humanH,boxCol,0,boxCol[4]or 255,(self.boxThickness or 1)*s)end
    if self.features.skeleton then local sk=self.colors.skeleton or self:_theme("white");local cx=bx+humanW*.5;local hy=by+humanH*.15;circle(cx,hy,humanW*.08,sk,255);line(cx,hy+humanW*.08,cx,by+humanH*.55,sk,1*s);line(cx,by+humanH*.3,bx+humanW*.22,by+humanH*.48,sk,1*s);line(cx,by+humanH*.3,bx+humanW*.78,by+humanH*.48,sk,1*s);line(cx,by+humanH*.55,bx+humanW*.3,by+humanH*.9,sk,1*s);line(cx,by+humanH*.55,bx+humanW*.7,by+humanH*.9,sk,1*s)end
    local health=self:_currentHealth();local hpCol=self.colors.health or{92,213,117,255};self.positions.healthbar=espSlot92(self.positions.healthbar or 4)
    local dragKind=self._espDrag;local hits={};local function hit(kind,xx,yy,ww,hh)hits[#hits+1]={kind=kind,x=xx,y=yy,w=ww,h=hh}end
    local function drawHealth(side,drag)
        if side==4 or side==6 then local hx=side==4 and bx-11*s or bx+humanW+7*s;local hy=by;if drag then hx=Input.mx;hy=Input.my-humanH*.5 end;rect(hx,hy,5*s,humanH,{12,13,17,255},2*s,220);local fh=humanH*health/100;rect(hx,hy+humanH-fh,5*s,fh,hpCol,2*s,hpCol[4]or 255);return hx-8*s,hy-5*s,21*s,humanH+10*s
        else local hx=bx;local hy=side==2 and by-11*s or by+humanH+7*s;if drag then hx=Input.mx-humanW*.5;hy=Input.my end;rect(hx,hy,humanW,5*s,{12,13,17,255},2*s,220);rect(hx,hy,humanW*health/100,5*s,hpCol,2*s,hpCol[4]or 255);return hx-5*s,hy-8*s,humanW+10*s,21*s end
    end
    if self.features.healthbar~=false and(self.healthStyle=="bar"or self.healthStyle=="both"or self.healthStyle==nil)and dragKind~="healthbar"then local hx,hy,hw,hh=drawHealth(self.positions.healthbar,false);hit("healthbar",hx,hy,hw,hh)end
    local groups={};local function add(kind,textv,col)if not self.features[kind]or dragKind==kind then return end;local slot=espSlot92(self.positions[kind]or(kind=="distance"and 8 or(kind=="healthtext"and 6 or 2)));self.positions[kind]=slot;groups[slot]=groups[slot]or{};groups[slot][#groups[slot]+1]={kind=kind,text=textv,col=col}end
    add("name",self.texts.name or"Player",self.colors.name or self:_theme("text"));if self.features.healthtext or self.healthStyle=="text"or self.healthStyle=="both"then self.features.healthtext=true;add("healthtext","HP: "..tostring(round(health)),hpCol)end;add("distance",self.texts.distance or"42m",self.colors.distance or self:_theme("muted"))
    for slot,list in pairs(groups)do sort(list,function(a,b)return(self.order[a.kind]or 99)<(self.order[b.kind]or 99)end);local ax,ay,row,col=slotInfo92(slot,bx,by,humanW,humanH,12*s);local lineH=18*s;local maxW=0;for _,it in ipairs(list)do maxW=max(maxW,measure(it.text,13*s,"Verdana"))end;local total=#list*lineH;local sx=col==1 and(ax-8*s-maxW)or(col==2 and(ax-maxW*.5)or ax+8*s);local sy=row==1 and(ay-8*s-total)or(row==2 and(ay-total*.5)or ay+8*s);for i,it in ipairs(list)do local tw=measure(it.text,13*s,"Verdana");local tx=col==1 and(sx+maxW-tw)or(col==2 and(sx+(maxW-tw)*.5)or sx);local ty=sy+(i-1)*lineH;text(it.text,tx,ty,it.col,13*s,"Verdana");hit(it.kind,tx-4*s,ty-3*s,tw+8*s,18*s)end end
    if self.features.snapline then line(stageX+stageW*.5,stageY+stageH,bx+humanW*.5,by+humanH,self.colors.snapline or self:_theme("accent"),1*s,200)end
    -- ESP element drag has first pointer ownership. Start from held-left as well as click so
    -- runtimes that consume the click edge earlier in the Window pass still drag correctly.
    if self.editable and not self._espDrag and(Input.click or Input.left)and(not win or not win._hasPopup or not win:_hasPopup())then
        for i=#hits,1,-1 do local q=hits[i];if self:_hitESP(Input.mx,Input.my,q.x,q.y,q.w,q.h)then self._espDrag=q.kind;self._espDragStarted=true;E.pointerConsumed=true;if win then win._consumed=true end;break end end
    end
    if self._espDrag then
        E.pointerConsumed=true;if win then win._consumed=true end
        local kind=self._espDrag;local near=nearestSlot92(Input.mx,Input.my,bx,by,humanW,humanH,kind=="healthbar")
        for _,slot in ipairs(kind=="healthbar"and{2,4,6,8}or{1,2,3,4,6,7,8,9})do local ax,ay=slotInfo92(slot,bx,by,humanW,humanH,12*s);local active=slot==near;circle(ax,ay,(active and 4 or 2.5)*s,active and self:_theme("accent")or self:_theme("muted"),active and 255 or 180)end
        if kind=="healthbar"then drawHealth(near,true)else local label=kind=="name"and(self.texts.name or"Player")or(kind=="distance"and(self.texts.distance or"42m")or("HP: "..tostring(round(health))));local col=kind=="name"and(self.colors.name or self:_theme("text"))or(kind=="distance"and(self.colors.distance or self:_theme("muted"))or hpCol);local tw=measure(label,13*s,"Verdana");text(label,Input.mx-tw*.5,Input.my-7*s,col,13*s,"Verdana")end
        if not Input.left then espReorder92(self,kind,near,Input.my,bx,by,humanW,humanH);self.positions[kind]=near;self._espDrag=nil;self._espDragStarted=nil end
    end
end

function Window:_render()
    if self.destroyed then return end
    if self._pendingScale then local q=self._pendingScale;self._pendingScale=nil;applyScale93(self,q)end
    self:_toggleByKey();self:_processKeybinds();self:_processBindCapture();self:_processInputEdit();self:_processSliderEdit();if not self.visible then return end
    self._inRender=true;self._consumed=false;self:_updateWindowDragResize();local s=self.scale;local X,Y=self.x,self.y;local W,H=self.width*s,self.height*s
    if Input.click and not self._consumed and self:_hasPopup()then
        local inside=false;for _,p in pairs({openDrop=self.openDrop,extraPopup=self.extraPopup,keyMenu=self.keyMenu,colorPopup=self.colorPopup,colorMenu=self.colorMenu,configPopup=self.configPopup,groupPopup=self.groupPopup})do if p and p.x and p.y and p.w and p.h and self:_hit(p.x,p.y,p.w,p.h)then inside=true break end end
        if self.accountOpen then local _,py=self:_sidebarGeometry();if self:_hit(X+7*s,py-244*s,261*s,236*s)or self:_hit(X+15*s,py,245*s,55*s)then inside=true end end
        if not inside then self:_closePopups();self:_consume()end
    end
    self:_fill("main",X,Y,W,H,"menuBg",self.corner*s);self:_drawContent()
    local r=self.corner*s
    if self.kind=="Panel"or self.tabBarVisible==false then
        local topH=72*s;local botH=18*s
        maskTop93(self,X,Y,W,topH,r);maskBottom93(self,X,Y+H-botH,W,botH,r)
        local midY=Y+topH;local midH=max(0,H-topH-botH);if midH>0 then self:_fill("main",X,midY,18*s,midH,"menuBg",0);self:_fill("main",X+W-18*s,midY,18*s,midH,"menuBg",0)end
        self:_drawPanelHeader()
    else
        local topH=REF.ContentTop*s;local botH=15*s
        maskTop93(self,X,Y,W,topH,r);maskBottom93(self,X,Y+H-botH,W,botH,r)
        local midY=Y+topH;local midH=max(0,H-topH-botH);if midH>0 then self:_fill("main",X,midY,REF.ContentX*s,midH,"menuBg",0);self:_fill("main",X+W-REF.RightMargin*s,midY,REF.RightMargin*s,midH,"menuBg",0)end
        self:_drawSidebar();self:_drawTopbar()
    end
    self:_out(X,Y,W,H,r,self.borderThickness,self.outlineColor,255)
    self:_drawDropdownPopup();self:_drawExtraPopup();self:_drawKeyMenu();self:_drawColorPopup();self:_drawColorMenu();self:_drawConfigPopup();self:_drawGroupPopup();self:_drawAccountPopup();self:_drawSearchPopup();self._inRender=false
end

Fawn.Runtime.Resize="deferred mouse-anchored UI scale + frozen screen-space physical resize"
Fawn.Runtime.Clipping="full-row Section containment + rounded body masks; no native text may escape a Section/page viewport"
Fawn.Runtime.Scrollbar="accent hover/drag feedback for Section, page and sidebar scrollbars"
Fawn.Runtime.ESPWidgets="original Fawn cursor-follow drag parity + slot commit + stacking reorder + reset/shuffle"


-- Compatibility layer: scroll/accessory/layout polish.
REF.PageScrollbarGutter=12
REF.SectionScrollbarGutter=12
REF.AccessoryWidth=318
Fawn.Style.SmoothDropdownScrollbar=true
Fawn.Style.CompactColorPopup=true
Fawn.Rules.ScrollbarsUseReservedGutters=true
Fawn.Rules.BackspaceClearsCapturedKey=true
Fawn.Rules.RightClickKeybindModeMenu=true
Fawn.Rules.AccessoryPopupExtensible=true

-- Accessory content for the same three-dot popup that contains an embedded hotkey.
local function ensureAccessory94(c)
    if c.extraSection and alive(c.extraSection)then return c.extraSection end
    local sec=setmetatable({kind="Section",id=newId("accessory"),name="ACCESSORY",tab=c.tab,window=c.window,controls={},column=1,row=1,span=1,columns=1,controlGap=0,sizeMode="auto",visible=true,scroll=0,scrollTarget=0,maxScroll=0,scrollStep=REF.Compact.rowH},Section)
    sec.accessoryOwner=c
    c.extraSection=sec
    return sec
end
function Control:Extra(fn)
    local sec=ensureAccessory94(self)
    if type(fn)=="function"then fn(sec)end
    return self
end
Control.extra=Control.Extra
Control.AddExtra=Control.Extra
function Control:GetExtraSection()return self.extraSection end
function Control:ClearExtra()
    if self.extraSection then for i=#self.extraSection.controls,1,-1 do local c=self.extraSection.controls[i];if alive(c)then c:Destroy()end end;self.extraSection.controls={}end
    return self
end
function Control:AddAccessoryToggle(...)return ensureAccessory94(self):AddToggle(...)end
function Control:AddAccessorySlider(...)return ensureAccessory94(self):AddSlider(...)end
function Control:AddAccessoryDropdown(...)return ensureAccessory94(self):AddDropdown(...)end
function Control:AddAccessoryMultiSelect(...)return ensureAccessory94(self):AddMultiSelect(...)end
function Control:AddAccessoryInput(...)return ensureAccessory94(self):AddInput(...)end
function Control:AddAccessoryColorPicker(...)return ensureAccessory94(self):AddColorPicker(...)end
function Control:AddAccessoryKeybind(...)return ensureAccessory94(self):AddKeybind(...)end
function Control:AddAccessoryButton(...)return ensureAccessory94(self):AddButton(...)end
function Control:AddAccessoryLabel(...)return ensureAccessory94(self):AddLabel(...)end

-- Backspace is the clear key. Escape cancels capture without changing the current bind.
function Window:_processBindCapture()
    local c=self.captureBind;if not c then return end
    if not alive(c)then self.captureBind=nil return end
    if self._captureFrame and E.paintCount<=self._captureFrame then return end
    if Input.pressed.Escape or Input.pressed.escape then self.captureBind=nil return end
    if Input.pressed.Backspace or Input.pressed.backspace then c:ClearKey();self.captureBind=nil return end
    local choices={{"Mouse1",1},{"Mouse2",2},{"Mouse3",4},{"Mouse4",5},{"Mouse5",6}}
    for _,q in ipairs(choices)do if keyState(q[2])then if not c.keyboardOnly then c:SetKey(q[1],q[1])end;self.captureBind=nil return end end
    for _,k in ipairs(POLL)do if Input.pressed[k]then if k~="Escape"and k~="Backspace"and(sub(k,1,5)~="Mouse"or not c.keyboardOnly)then c:SetKey(k,k)end;self.captureBind=nil return end end
end

-- Right-click keybind mode menu: Hold / Toggle / Always On. Clearing is Backspace while capturing.
function Window:_drawKeyMenu()
    local p=self.keyMenu;if not p then return end
    local c=p.control;if not alive(c)then self.keyMenu=nil return end
    local s=self.scale;local C=REF.Compact
    local items={{"Hold","Hold"},{"Toggle","Toggle"},{"Always On","Always"}}
    p.h=#items*C.itemH*s+12*s;p.w=max(p.w or 162*s,162*s);p.anchorY=p.y-6*s
    self:_clampPopup(p);self:_popupFrame(p)
    for i,it in ipairs(items)do
        local y=p.y+6*s+(i-1)*C.itemH*s;local hov=self:_hit(p.x+5*s,y,p.w-10*s,C.itemH*s);local sel=c.mode==it[2]
        if hov then self:_fill("control",p.x+5*s,y,p.w-10*s,C.itemH*s,"controlHover",C.itemR*s)elseif sel then rect(p.x+5*s,y,p.w-10*s,C.itemH*s,self:_color("accent"),C.itemR*s,20)end
        textC(it[1],p.x+12*s,y+C.itemH*s*.5,self:_color(sel and"accent"or"text"),C.itemFont*s,"Verdana")
        if sel then ICON.check(p.x+p.w-20*s,y+C.itemH*s*.5,12*s,self:_color("accent"))end
        if Input.click and not self._consumed and hov then c:SetMode(it[2]);self.keyMenu=nil;self:_consume()end
    end
end

local function accessoryRow94(win,c,x,y,w,h,C)
    local s=win.scale;local left=x+C.padL*s;local right=x+w-C.padR*s;local cy=y+h*.5
    local labelW=max(30*s,w*.42);local label=fit(c.label or"",labelW,C.font*s,"Verdana")
    if c.type~="button"and c.type~="label"and c.type~="separator"then textC(label,left,cy,win:_color("text"),C.font*s,"Verdana")end
    if c.type=="toggle"then
        local tw,th=C.togW*s,C.togH*s;local tx=right-tw;local ty=cy-th*.5;local on=c.value==true
        rect(tx,ty,tw,th,on and win:_color("accent")or win:_color("toggleTrack"),th*.5,255);local kp=(th-C.knob*s)*.5;circle(on and(tx+tw-kp-C.knob*s*.5)or(tx+kp+C.knob*s*.5),cy,C.knob*s*.5,win:_color("white"),255)
        if Input.click and not win._consumed and win:_hit(tx,ty,tw,th)then c:Set(not on);win:_consume()end
    elseif c.type=="slider"then
        local value=c.value or c.min;local display=win:_sliderDisplay(c,value);local vw=max(48*s,measure(display,C.valFont*s,"Verdana")+C.valPad*2*s);local vx=right-vw;local vh=C.valH*s;local vy=cy-vh*.5
        local sx=left+labelW;local sw=max(28*s,vx-C.sGap*s-sx);rect(sx,cy-2*s,sw,4*s,win:_color("control"),2*s,255);local range=max(.00001,c.max-c.min);local q=clamp((clamp(value,c.min,c.max)-c.min)/range,0,1);local kx=sx+q*sw;rect(sx,cy-2*s,max(0,kx-sx),4*s,win:_color("accent"),2*s,255);circle(kx,cy,max(4*s,C.sKnob*s*.32),win:_color("white"),255)
        win:_fill("control",vx,vy,vw,vh,"control",C.valR*s);local tw=measure(display,C.valFont*s,"Verdana");textC(display,vx+(vw-tw)*.5,cy,win:_color("text"),C.valFont*s,"Verdana")
        if c._accessoryDrag then if Input.left then c:Set(c.min+clamp((Input.mx-sx)/max(1,sw),0,1)*(c.max-c.min))else c._accessoryDrag=nil end end
        if Input.click and not win._consumed and win:_hit(sx,cy-15*s,sw,30*s)then c._accessoryDrag=true;c:Set(c.min+clamp((Input.mx-sx)/max(1,sw),0,1)*(c.max-c.min));win:_consume()end
    elseif c.type=="dropdown"or c.type=="multiselect"then
        local fw=min(148*s,max(82*s,w*.48));local fh=C.ddH*s;local fx=right-fw;local fy=cy-fh*.5;local hov=win:_hit(fx,fy,fw,fh);win:_fill("control",fx,fy,fw,fh,hov and"controlHover"or"control",C.ddR*s)
        local textv=c.type=="multiselect"and c:GetSummary()or tostring(c:Get()or"None");textC(fit(textv,fw-34*s,C.ddFont*s,"Verdana"),fx+C.ddPadL*s,cy,win:_color("text"),C.ddFont*s,"Verdana");chevDown(fx+fw-C.ddPadR*s-C.chev*s*.5,cy,C.chev*s,win:_color("chev"),win.openDrop and win.openDrop.control==c)
        if Input.click and not win._consumed and hov then win:_openDropdown(c,fx,fy,fw,fh);win:_consume()end
    elseif c.type=="keybind"then
        local shown=win:_keyLabel(c);local tw=measure(shown,C.keyFont*s,"Verdana");local fw=min(138*s,max(76*s,tw+C.keyPad*2*s));local fh=C.keyH*s;local fx=right-fw;local fy=cy-fh*.5;local hov=win:_hit(fx,fy,fw,fh);win:_fill("control",fx,fy,fw,fh,hov and"controlHover"or"control",C.keyR*s);textC(shown,fx+(fw-tw)*.5,cy,win.captureBind==c and win:_color("accent")or win:_color("text"),C.keyFont*s,"Verdana")
        if Input.click and not win._consumed and hov then win.captureBind=c;win._captureFrame=E.paintCount;win:_consume()elseif Input.rightClick and not win._consumed and hov then win.keyMenu={control=c,x=fx,y=fy+fh+5*s,w=162*s,h=3*C.itemH*s};win:_consume()end
    elseif c.type=="color"then
        win:_drawColorChip(c,right,cy,C,true)
    elseif c.type=="input"then
        local fw=min(150*s,max(86*s,w*.48));local fh=C.ddH*s;local fx=right-fw;local fy=cy-fh*.5;local hov=win:_hit(fx,fy,fw,fh);win:_fill("control",fx,fy,fw,fh,hov and"controlHover"or"control",C.ddR*s);local raw=tostring(c.value or"");local shown=raw==""and tostring(c.placeholder or"")or(c.password and string.rep("*",#raw)or raw);textC(fit(shown,fw-18*s,C.ddFont*s,"Verdana"),fx+C.ddPadL*s,cy,win:_color(raw==""and"muted"or"text"),C.ddFont*s,"Verdana");c._inputRect={fx,fy,fw,fh};if Input.click and not win._consumed and hov then win:_focusInput(c);win:_consume()end
    elseif c.type=="button"then
        local bx=left;local bw=right-left;local bh=max(28*s,h-12*s);local by=cy-bh*.5;local hov=win:_hit(bx,by,bw,bh);win:_fill("control",bx,by,bw,bh,hov and"controlHover"or"control",8*s);local txt=fit(c.label,bw-18*s,C.font*s,"Verdana");local tw=measure(txt,C.font*s,"Verdana");textC(txt,bx+(bw-tw)*.5,cy,win:_color("text"),C.font*s,"Verdana");if Input.click and not win._consumed and hov then if type(c.fn)=="function"then pcall(c.fn,c)end;win:_consume()end
    elseif c.type=="label"then
        local lines=wrapText(c.label,max(20,right-left),C.font*s,"Verdana",c.maxLines or 3);local lh=17*s;win:_drawWrapped(lines,left,cy-#lines*lh*.5,win:_color("text"),C.font*s,lh,false)
    elseif c.type=="separator"then
        local t=fit(upper(c.label),max(20,right-left),11*s,"Verdana");textC(t,left,cy,win:_color("muted"),11*s,"Verdana")
    end
end

function Window:_drawExtraPopup()
    local p=self.extraPopup;if not p then return end
    local parent=p.control;if not alive(parent)then self.extraPopup=nil return end
    local s=self.scale;local C=REF.Compact;local k=parent.keybind;local extras=parent.extraSection and parent.extraSection.controls or{}
    local keyRows=(k and not k.accessoryOnly)and 1 or 0;local visibleExtras={};for _,c in ipairs(extras)do if alive(c)and visibilityPass(c)then visibleExtras[#visibleExtras+1]=c end end
    local count=keyRows+#visibleExtras;local header=34*s;local rowH=C.rowH*s
    p.w=REF.AccessoryWidth*s;p.h=header+max(1,count)*rowH+8*s;p.anchorY=p.anchorY or p.y-8*s;self:_clampPopup(p);self:_popupFrame(p)
    textC("OPTIONS",p.x+14*s,p.y+18*s,self:_color("muted"),12*s,"Verdana")
    local y=p.y+header
    if k and not k.accessoryOnly then
        local shown=self:_keyLabel(k);local tw=measure(shown,C.keyFont*s,"Verdana");local fw=min(126*s,max(76*s,tw+C.keyPad*2*s));local fh=C.keyH*s;local fx=p.x+p.w-C.padR*s-fw;local fy=y+(rowH-fh)*.5;local cy=y+rowH*.5;local hov=self:_hit(fx,fy,fw,fh)
        textC("Keybind",p.x+C.padL*s,cy,self:_color("text"),C.font*s,"Verdana");self:_fill("control",fx,fy,fw,fh,hov and"controlHover"or"control",C.keyR*s);textC(shown,fx+(fw-tw)*.5,cy,self.captureBind==k and self:_color("accent")or self:_color("text"),C.keyFont*s,"Verdana")
        if Input.click and not self._consumed and hov then self.captureBind=k;self._captureFrame=E.paintCount;self.inputEdit=nil;self:_consume()elseif Input.rightClick and not self._consumed and hov then self.keyMenu={control=k,x=fx,y=fy+fh+5*s,w=162*s,h=3*C.itemH*s};self:_consume()end
        y=y+rowH
    end
    for _,c in ipairs(visibleExtras)do accessoryRow94(self,c,p.x,y,p.w,rowH,C);y=y+rowH end
end

-- Smaller Fawn HSV color popup while keeping the original picker interaction model.
function Window:_drawColorChip(c,right,cy,F,interactive)
    local s=self.scale;local sz=F.sw*s;local x=right-sz;local y=cy-sz*.5;local tile=max(3,5*s)
    for yy=0,1 do for xx=0,1 do rect(x+xx*sz*.5,y+yy*sz*.5,sz*.5+1,sz*.5+1,((xx+yy)%2==0)and{71,72,78,255}or{35,36,41,255},F.swR*s,255)end end
    rect(x+1*s,y+1*s,sz-2*s,sz-2*s,c.value,max(1,F.swR*s-1*s),c.value[4]or 255);outline(x,y,sz,sz,self:_color("outline"),F.swR*s,150,max(1,s))
    if interactive and not self._consumed then
        if Input.click and not self:_hasPopup()and self:_hit(x,y,sz,sz)then self.colorPopup={control=c,x=x+sz-240*s,y=y+sz+6*s,w=240*s,h=244*s};self:_consume()
        elseif Input.rightClick and not self:_hasPopup()and self:_hit(x,y,sz,sz)then self.colorMenu={control=c,x=Input.mx,y=Input.my,w=160*s,h=88*s};self:_consume()end
    end
    return x,y,sz,sz
end
function Window:_drawColorPopup()
    local p=self.colorPopup;if not p then return end;local c=p.control;if not alive(c)then self.colorPopup=nil return end
    local s=self.scale;p.w=240*s;p.h=244*s;p.anchorY=p.y-6*s;self:_clampPopup(p);self:_popupFrame(p)
    local arr=c.value;local hue,sat,val=rgbToHsv92(arr[1],arr[2],arr[3]);local svx,svy,svw,svh=p.x+12*s,p.y+42*s,170*s,116*s;local hx,hy,hw,hh=p.x+192*s,p.y+42*s,18*s,116*s;local ax,ay,aw,ah=p.x+12*s,p.y+184*s,198*s,14*s
    textC(upper(c.label or"COLOR"),p.x+12*s,p.y+18*s,self:_color("text"),14*s,"Verdana")
    local cols,rows=34,24;local cw,ch=svw/cols,svh/rows
    for iy=0,rows-1 do local vv=1-iy/(rows-1);for ix=0,cols-1 do local ss=ix/(cols-1);local r,g,b=hsvToRgb92(hue,ss,vv);rect(svx+ix*cw,svy+iy*ch,cw+1.2,ch+1.2,{r,g,b,255},0,255)end end
    outline(svx-1,svy-1,svw+2,svh+2,self:_color("outline"),5*s,170,max(1,s));local sx,sy=svx+sat*svw,svy+(1-val)*svh;circle(sx,sy,3.5*s,self:_color("white"),255);outline(sx-4.5*s,sy-4.5*s,9*s,9*s,self:_color("black"),4.5*s,180,max(1,s))
    for i=0,59 do local r,g,b=hsvToRgb92(i/59,1,1);rect(hx,hy+i*(hh/60),hw,hh/60+1,{r,g,b,255},0,255)end;outline(hx-1,hy-1,hw+2,hh+2,self:_color("outline"),4*s,170,max(1,s));rect(hx-2*s,hy+hue*hh-1*s,hw+4*s,2*s,self:_color("white"),1*s,255)
    local tile=5*s;for yy=0,2 do for xx=0,ceil(aw/tile)-1 do rect(ax+xx*tile,ay+yy*tile,tile+1,tile+1,((xx+yy)%2==0)and{72,70,78,255}or{39,38,44,255},0,255)end end;for xx=0,max(1,floor(aw))-1 do local aa=round(xx/max(1,floor(aw)-1)*255);rect(ax+xx,ay,1,ah,{arr[1],arr[2],arr[3],255},0,aa)end;outline(ax,ay,aw,ah,self:_color("outline"),5*s,170,max(1,s));local alphaX=ax+(arr[4]or 255)/255*aw;rect(alphaX-1*s,ay-1*s,2*s,ah+2*s,self:_color("white"),1*s,255)
    local hex=format("#%02X%02X%02X",arr[1],arr[2],arr[3]);local ap=round((arr[4]or 255)/255*100);self:_fill("control",p.x+12*s,p.y+210*s,96*s,23*s,"control",5*s);self:_fill("control",p.x+116*s,p.y+210*s,94*s,23*s,"control",5*s);local q=measure(hex,12*s,"Verdana");textC(hex,p.x+60*s-q*.5,p.y+221*s,self:_color("text"),12*s,"Verdana");local at=tostring(ap).."%";q=measure(at,12*s,"Verdana");textC(at,p.x+163*s-q*.5,p.y+221*s,self:_color("muted"),12*s,"Verdana")
    if Input.click and not self._consumed then if self:_hit(svx,svy,svw,svh)then p.drag="sv";self:_consume()elseif self:_hit(hx,hy,hw,hh)then p.drag="h";self:_consume()elseif self:_hit(ax,ay,aw,ah)then p.drag="a";self:_consume()end end
    if p.drag then if Input.left then local h0,s0,v0=rgbToHsv92(arr[1],arr[2],arr[3]);local q=copy(arr);if p.drag=="sv"then s0=clamp((Input.mx-svx)/svw,0,1);v0=1-clamp((Input.my-svy)/svh,0,1);q[1],q[2],q[3]=hsvToRgb92(h0,s0,v0)elseif p.drag=="h"then h0=clamp((Input.my-hy)/hh,0,1);q[1],q[2],q[3]=hsvToRgb92(h0,s0,v0)else q[4]=round(clamp((Input.mx-ax)/aw,0,1)*255)end;c:Set(q)else p.drag=nil end end
end

-- Reserve scrollbar gutters at layout time so scrollbars never overlap controls or change wrapping after overflow appears.
local _sectionControlLayout93=Window._sectionControlLayout
function Window:_sectionControlLayout(section,cardX,cardY,cardW)
    local reserve=((section.sizeMode=="fixed"or section.sizeMode=="fill"or section.maxHeight)and REF.SectionScrollbarGutter or 0)*self.scale
    return _sectionControlLayout93(self,section,cardX,cardY,max(40*self.scale,cardW-reserve))
end

function Window:_buildLayout(tab)
    local s=self.scale;local panel=self.kind=="Panel"or self.tabBarVisible==false
    local bodyX=panel and(self.x+18*s)or self:_sx(REF.ContentX);local bodyY=panel and(self.y+72*s)or self:_sy(REF.ContentTop)
    local rawBodyW=max(1,panel and((self.width-36)*s)or((self.width-REF.ContentX-REF.RightMargin)*s));local fullBodyH=max(1,panel and((self.height-90)*s)or((self.height-REF.ContentTop-15)*s));local pageGutter=REF.PageScrollbarGutter*s;local usableBodyW=max(40*s,rawBodyW-pageGutter)
    local bodyW,bodyH=usableBodyW,fullBodyH;local preview=nil;local cols=clamp(self.columns,1,4);local gap=REF.ColumnGap*s
    if tab and alive(tab.dockedPreview)and tab.dockedPreview.visible~=false and tab.dockedPreview.docked~=false then local dp=tab.dockedPreview;local pgap=(dp.dockGap or REF.ColumnGap)*s;local desired=clamp(usableBodyW*(dp.dockWidthRatio or .36),220*s,440*s);local minContent=max(260*s,cols*235*s+gap*(cols-1));local mode=dp.dockMode or"auto";local sideOK=(usableBodyW-desired-pgap)>=minContent
        if mode=="side"or(mode=="auto"and sideOK)then local pw=min(desired,max(180*s,usableBodyW-minContent-pgap));bodyW=max(1,usableBodyW-pw-pgap);preview={x=bodyX+bodyW+pgap,y=bodyY,w=pw,h=fullBodyH,mode="side"}
        else local ph=clamp(fullBodyH*(dp.dockHeightRatio or .38),190*s,340*s);bodyH=max(120*s,fullBodyH-ph-pgap);preview={x=bodyX,y=bodyY+bodyH+pgap,w=usableBodyW,h=min(ph,fullBodyH-bodyH-pgap),mode="bottom"}end end
    local colW=max(40*s,(bodyW-gap*(cols-1))/cols);local sections,rowsMap={},{}
    for _,sec in ipairs(tab.sections)do if alive(sec)and visibilityPass(sec)then local row=max(1,floor(sec.row or 1));rowsMap[row]=rowsMap[row]or{};rowsMap[row][#rowsMap[row]+1]=sec end end
    local rowNums={}for r in pairs(rowsMap)do rowNums[#rowNums+1]=r end;sort(rowNums);local y=bodyY-(tab.pageScroll or 0);local contentBottom=bodyY
    for _,row in ipairs(rowNums)do local rowSecs=rowsMap[row];local rowH=0;local pre={}
        for _,sec in ipairs(rowSecs)do local col=clamp(floor(sec.column or 1),1,cols);local span=clamp(floor(sec.span or 1),1,cols-col+1);local x=bodyX+(col-1)*(colW+gap);local w=max(40*s,colW*span+gap*(span-1));local layouts,contentH=self:_sectionControlLayout(sec,x,y+30*s,w);local total
            if sec.sizeMode=="fixed"then total=max(30*s+63*s,(tonumber(sec.height)or 240)*s)elseif sec.sizeMode=="fill"then total=max(30*s+63*s,bodyY+bodyH-y)else total=30*s+contentH end;if sec.minHeight then total=max(total,sec.minHeight*s)end;if sec.maxHeight then total=min(total,sec.maxHeight*s)end;pre[#pre+1]={sec=sec,x=x,w=w,layouts=layouts,contentH=contentH,total=total};rowH=max(rowH,total)end
        for _,q in ipairs(pre)do local sec=q.sec;local total=q.total;if sec.sizeMode=="fill"then total=rowH end;local cardY=y+30*s;local cardH=max(1,total-30*s);sec.maxScroll=sectionInternalScroll92(sec,q.contentH,cardH);sec.scrollTarget=clamp(sec.scrollTarget or 0,0,sec.maxScroll);if self.resizing or self.smoothScroll==false then sec.scroll=sec.scrollTarget else sec.scroll=(sec.scroll or 0)+(sec.scrollTarget-(sec.scroll or 0))*min(1,dt()*self.scrollSpeed)end;sec.scroll=clamp(sec.scroll or 0,0,sec.maxScroll);sec.resolvedHeight=total/s;sections[#sections+1]={section=sec,x=q.x,y=y,w=q.w,h=total,cardY=cardY,cardH=cardH,layouts=q.layouts,contentH=q.contentH};contentBottom=max(contentBottom,y+total)end
        y=y+rowH+REF.SectionGap*s;contentBottom=max(contentBottom,y)
    end
    local contentH=max(0,contentBottom-bodyY-(#rowNums>0 and REF.SectionGap*s or 0));tab.maxScroll=max(0,contentH-bodyH);if self.mainScrollEnabled~=false and tab.mainScrollEnabled~=false then tab.pageTarget=clamp(tab.pageTarget or 0,0,tab.maxScroll)else tab.pageTarget=0 end;if self.resizing or self.smoothScroll==false then tab.pageScroll=tab.pageTarget else tab.pageScroll=(tab.pageScroll or 0)+(tab.pageTarget-(tab.pageScroll or 0))*min(1,dt()*self.scrollSpeed)end;tab.pageScroll=clamp(tab.pageScroll or 0,0,tab.maxScroll)
    self._layout={bodyX=bodyX,bodyY=bodyY,bodyW=bodyW,fullBodyW=rawBodyW,usableBodyW=usableBodyW,pageGutter=pageGutter,bodyH=bodyH,fullBodyH=fullBodyH,sections=sections,contentH=contentH,maxScroll=tab.maxScroll,preview=preview};return self._layout
end

-- Minimal gutter scrollbars: neutral at rest, accent on hover/drag, never painted through control content.
function Window:_drawSection(box,bodyTop,bodyBottom,bodyLeft,bodyRight)
    local sec=box.section;local s=self.scale;local cardTop=box.cardY;local cardBottom=cardTop+box.cardH;local clipL=max(bodyLeft or box.x,box.x);local clipR=min(bodyRight or(box.x+box.w),box.x+box.w);local clipT=max(bodyTop,cardTop);local clipB=min(bodyBottom,cardBottom);local fullCard=clipL==box.x and clipR==box.x+box.w and clipT==cardTop and clipB==cardBottom;if clipB<=clipT or clipR<=clipL then return end
    self:_fill("card",clipL,clipT,clipR-clipL,clipB-clipT,"card",fullCard and 14*s or 0)
    local rows={}for c,r in pairs(box.layouts)do rows[#rows+1]={c=c,r=r}end;sort(rows,function(a,b)if a.r.y==b.r.y then return a.r.x<b.r.x end return a.r.y<b.r.y end);local offset=sec.scroll or 0
    for _,q in ipairs(rows)do local r={x=q.r.x,y=q.r.y-offset,w=q.r.w,h=q.r.h};if r.y>=clipT-.25 and r.y+r.h<=clipB+.25 and r.x>=clipL-.25 and r.x+r.w<=clipR+.25 then self:_drawControl(q.c,r,clipT,clipB)end end
    if sec.columnDividers==true and sec.columns and sec.columns>1 and fullCard then local gap=(sec.controlGap or 12)*s;local usable=box.w-(((sec.sizeMode=="fixed"or sec.sizeMode=="fill"or sec.maxHeight)and REF.SectionScrollbarGutter or 0)*s);local cw=(usable-gap*(sec.columns-1))/sec.columns;for i=1,sec.columns-1 do local x=box.x+i*cw+(i-.5)*gap;line(x,cardTop+8*s,x,cardBottom-8*s,self:_color("line"),1,14)end end
    if fullCard then self:_out(box.x,cardTop,box.w,box.cardH,14*s,.8,self:_color("outline"),110)end
    if sec.maxScroll>1 then local gutter=REF.SectionScrollbarGutter*s;local gx=box.x+box.w-gutter;self:_fill("card",gx,clipT,gutter,clipB-clipT,"card",0);local tx=gx+gutter*.5;local top=clipT+8*s;local bh=max(1,clipB-clipT-16*s);local thumb=max(28*s,bh*(box.cardH/max(box.cardH,box.contentH)));local span=max(1,bh-thumb);local ratio=(sec.scroll or 0)/sec.maxScroll;local ty=top+span*ratio;local trackHover=self:_hit(gx,clipT,gutter,clipB-clipT);local thumbHover=self:_hit(gx,ty-3*s,gutter,thumb+6*s);local active=sec._scrollDrag~=nil
        if trackHover or active then rect(tx-1*s,top,2*s,bh,self:_color("controlHover"),1*s,120)end;rect(tx-((active or thumbHover)and 2*s or 1.5*s),ty,(active or thumbHover)and 4*s or 3*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 190)
        if Input.click and not self._consumed and not self:_hasPopup()and thumbHover then sec._scrollDrag={top=top,span=span,off=Input.my-ty};self:_consume()end;if sec._scrollDrag then if Input.left then sec.scrollTarget=clamp((Input.my-sec._scrollDrag.top-sec._scrollDrag.off)/sec._scrollDrag.span,0,1)*sec.maxScroll;sec.scroll=sec.scrollTarget else sec._scrollDrag=nil end end
    else sec._scrollDrag=nil end
    local titleY=box.y+7*s;if titleY>=bodyTop-20*s and titleY<=bodyBottom and box.x>=bodyLeft-1 and box.x<=(bodyRight or box.x+box.w)then textC(fit(upper(sec.name),max(20,box.w-44*s),14*s,"Verdana"),box.x+22*s,titleY,self:_color("muted"),14*s,"Verdana")end
end

function Window:_drawContent()
    local s=self.scale;local tab=self:_activeTab();if not tab then return end;local layout=self:_buildLayout(tab);local top,bottom=layout.bodyY,layout.bodyY+layout.bodyH;local left,right=layout.bodyX,layout.bodyX+layout.bodyW;local pointerBody=self:_hit(left,top,layout.bodyW,layout.bodyH);local wheelOwned=false
    for _,box in ipairs(layout.sections)do local sec=box.section;local l=max(box.x,left);local r=min(box.x+box.w,right);local ht=max(box.cardY,top);local hb=min(box.cardY+box.cardH,bottom);if sec.maxScroll>1 and r>l and hb>ht and self:_hit(l,ht,r-l,hb-ht)and Input.wheel~=0 and not self:_hasPopup()then sec:ScrollBy(Input.wheel*sec:GetScrollStep());wheelOwned=true;break end end
    if not wheelOwned and pointerBody and Input.wheel~=0 and not self:_hasPopup()and tab.maxScroll>0 then tab:ScrollBy(Input.wheel*tab:GetScrollStep())end
    for _,box in ipairs(layout.sections)do if box.y+box.h>=top and box.y<=bottom and box.x+box.w>=left and box.x<=right then self:_drawSection(box,top,bottom,left,right)end end;if layout.preview and alive(tab.dockedPreview)then tab.dockedPreview:_renderDocked(layout.preview)end
    if #layout.sections==0 then local h=min(220*s,layout.bodyH);self:_fill("card",left,top,layout.bodyW,h,"card",14*s);self:_out(left,top,layout.bodyW,h,14*s,.8,self:_color("outline"),100);local msg="No settings on this tab yet";local tw,th=measure(msg,18*s,"Verdana");text(msg,left+(layout.bodyW-tw)*.5,top+(h-th)*.5,self:_color("muted"),18*s,"Verdana")end
    if tab.maxScroll>1 then local gx=layout.bodyX+layout.bodyW;local gutter=layout.pageGutter or REF.PageScrollbarGutter*s;local tx=gx+gutter*.5;local th=max(20*s,layout.bodyH-8*s);local ty=top+4*s;local thumb=max(32*s,th*(layout.bodyH/max(layout.bodyH,layout.contentH)));local span=max(1,th-thumb);local rr=(tab.pageScroll or 0)/tab.maxScroll;local yy=ty+span*rr;local trackHover=self:_hit(gx,top,gutter,layout.bodyH);local thumbHover=self:_hit(gx,yy-3*s,gutter,thumb+6*s);local active=tab._pageDrag~=nil
        if trackHover or active then rect(tx-1*s,ty,2*s,th,self:_color("controlHover"),1*s,120)end;rect(tx-((active or thumbHover)and 2*s or 1.5*s),yy,(active or thumbHover)and 4*s or 3*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 200)
        if Input.click and not self._consumed and not self:_hasPopup()and thumbHover then tab._pageDrag={top=ty,span=span,off=Input.my-yy};self:_consume()end;if tab._pageDrag then if Input.left then tab.pageTarget=clamp((Input.my-tab._pageDrag.top-tab._pageDrag.off)/tab._pageDrag.span,0,1)*tab.maxScroll;tab.pageScroll=tab.pageTarget else tab._pageDrag=nil end end
    else tab._pageDrag=nil end
end

-- Smooth dropdown content and thumb; scrollbar has its own gutter and no longer tears through rows.
function Window:_openDropdown(c,x,y,w,h)
    self.openDrop={control=c,x=x,y=y+h+6*self.scale,w=w,scroll=tonumber(c.dropdownScroll)or 0,scrollTarget=tonumber(c.dropdownScroll)or 0,scrollView=tonumber(c.dropdownScroll)or 0,triggerX=x,triggerY=y,triggerW=w,triggerH=h}
    self.keyMenu=nil;self.colorPopup=nil;self.colorMenu=nil;self.configPopup=nil;self.groupPopup=nil;self.accountOpen=false
end
function Window:_drawDropdownPopup()
    local p=self.openDrop;if not p then return end;local c=p.control;if not alive(c)or not visibilityPass(c)then self.openDrop=nil return end;if c.optionsSource then c:RefreshOptionsSource(false)end
    local s=self.scale;local F=REF.Full;local maxRows=min(c:GetMaxVisibleOptions(),max(1,#c.options));local margin=10*s;local rowH=F.itemH*s;p.h=margin*2+maxRows*rowH;p.w=p.w or F.ctrlW*s;p.anchorY=p.y-6*s;self:_clampPopup(p);self:_popupFrame(p)
    local maxScroll=max(0,#c.options-maxRows);p.scrollTarget=clamp(p.scrollTarget or p.scroll or c.dropdownScroll or 0,0,maxScroll);p.scrollView=clamp(p.scrollView or p.scrollTarget,0,maxScroll)
    local inside=self:_hit(p.x,p.y,p.w,p.h);if inside and Input.wheel~=0 then p.scrollTarget=clamp(p.scrollTarget+Input.wheel*c:GetDropdownScrollStep()*.72,0,maxScroll)end
    if p.drag then if Input.left then local ratio=clamp((Input.my-p.drag.top-p.drag.off)/max(1,p.drag.span),0,1);p.scrollTarget=ratio*maxScroll;p.scrollView=p.scrollTarget else p.drag=nil end else p.scrollView=p.scrollView+(p.scrollTarget-p.scrollView)*min(1,dt()*18)end
    local base=floor(p.scrollView);local frac=p.scrollView-base;local listTop=p.y+margin;local listBottom=p.y+p.h-margin;local gutter=10*s;local rowW=p.w-10*s-gutter
    for n=0,maxRows do local i=base+n+1;if i>#c.options then break end;local yy=listTop+n*rowH-frac*rowH;if yy<listBottom and yy+rowH>listTop then local hov=self:_hit(p.x+5*s,max(yy,listTop),rowW,min(yy+rowH,listBottom)-max(yy,listTop));local selected=c.type=="dropdown"and c.value==i or(c.type=="multiselect"and c.value[i]==true);if hov then self:_fill("control",p.x+5*s,yy,rowW,rowH,"controlHover",F.itemR*s)elseif selected then rect(p.x+5*s,yy,rowW,rowH,self:_color("accent"),F.itemR*s,24)end;local tcy=yy+rowH*.5;local safeText=tcy-F.itemFont*s*.7>=p.y+1*s and tcy+F.itemFont*s*.7<=p.y+p.h-1*s;if safeText then textC(fit(c.options[i],rowW-34*s,F.itemFont*s,"Verdana"),p.x+F.itemPad*s,tcy,self:_color(selected and"white"or"text"),F.itemFont*s,"Verdana");if selected then ICON.check(p.x+p.w-gutter-17*s,tcy,13*s,self:_color("accent"))end end;if Input.click and not self._consumed and hov then if c.type=="dropdown"then c:Set(i);self.openDrop=nil else c:ToggleOption(i)end;self:_consume()end end end
    -- Cover fractional-row text in the popup padding, then redraw the outer edge.
    self:_fill("popup",p.x+1*s,p.y+1*s,p.w-2*s,margin-1*s,"popup",9*s);self:_fill("popup",p.x+1*s,p.y+p.h-margin,p.w-2*s,margin-1*s,"popup",9*s);self:_out(p.x,p.y,p.w,p.h,10*s,.9,self:_color("outline"),150)
    if maxScroll>0 then local gx=p.x+p.w-gutter;local tx=gx+gutter*.5;local top=listTop;local th=listBottom-listTop;local thumb=max(22*s,th*(maxRows/#c.options));local span=max(1,th-thumb);local yy=top+span*(p.scrollView/maxScroll);local trackHover=self:_hit(gx,listTop,gutter,th);local thumbHover=self:_hit(gx,yy-3*s,gutter,thumb+6*s);local active=p.drag~=nil;if trackHover or active then rect(tx-1*s,top,2*s,th,self:_color("controlHover"),1*s,120)end;rect(tx-((active or thumbHover)and 2*s or 1.5*s),yy,(active or thumbHover)and 4*s or 3*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 195);if Input.click and not self._consumed and thumbHover then p.drag={top=top,span=span,off=Input.my-yy};self:_consume()end end
    p.scroll=clamp(round(p.scrollTarget),0,maxScroll);c.dropdownScroll=p.scroll
end

-- One clean solid outer outline; popup/card outlines keep their own softer alpha.
function Window:_render()
    if self.destroyed then return end;if self._pendingScale then local q=self._pendingScale;self._pendingScale=nil;applyScale93(self,q)end
    self:_toggleByKey();self:_processKeybinds();self:_processBindCapture();self:_processInputEdit();self:_processSliderEdit();if not self.visible then return end
    self._inRender=true;self._consumed=false;self:_updateWindowDragResize();local s=self.scale;local X,Y=self.x,self.y;local W,H=self.width*s,self.height*s
    if Input.click and not self._consumed and self:_hasPopup()then local inside=false;for _,p in pairs({openDrop=self.openDrop,extraPopup=self.extraPopup,keyMenu=self.keyMenu,colorPopup=self.colorPopup,colorMenu=self.colorMenu,configPopup=self.configPopup,groupPopup=self.groupPopup})do if p and p.x and p.y and p.w and p.h and self:_hit(p.x,p.y,p.w,p.h)then inside=true break end end;if self.accountOpen then local _,py=self:_sidebarGeometry();if self:_hit(X+7*s,py-244*s,261*s,236*s)or self:_hit(X+15*s,py,245*s,55*s)then inside=true end end;if not inside then self:_closePopups();self:_consume()end end
    self:_fill("main",X,Y,W,H,"menuBg",self.corner*s);self:_drawContent();local r=self.corner*s
    if self.kind=="Panel"or self.tabBarVisible==false then local topH=72*s;local botH=18*s;maskTop93(self,X,Y,W,topH,r);maskBottom93(self,X,Y+H-botH,W,botH,r);local midY=Y+topH;local midH=max(0,H-topH-botH);if midH>0 then self:_fill("main",X,midY,18*s,midH,"menuBg",0);self:_fill("main",X+W-18*s,midY,18*s,midH,"menuBg",0)end;self:_drawPanelHeader()
    else local topH=REF.ContentTop*s;local botH=15*s;maskTop93(self,X,Y,W,topH,r);maskBottom93(self,X,Y+H-botH,W,botH,r);local midY=Y+topH;local midH=max(0,H-topH-botH);if midH>0 then self:_fill("main",X,midY,REF.ContentX*s,midH,"menuBg",0);self:_fill("main",X+W-REF.RightMargin*s,midY,REF.RightMargin*s,midH,"menuBg",0)end;self:_drawSidebar();self:_drawTopbar()end
    local bt=max(1,round((self.borderThickness or 1)*(self.outlineStrength or 1)));local bi=bt*.5;outline(X+bi,Y+bi,max(1,W-bt),max(1,H-bt),self.outlineColor or self:_color("outline"),max(0,r-bi),255,bt)
    self:_drawExtraPopup();self:_drawDropdownPopup();self:_drawKeyMenu();self:_drawColorPopup();self:_drawColorMenu();self:_drawConfigPopup();self:_drawGroupPopup();self:_drawAccountPopup();self:_drawSearchPopup();self._inRender=false
end

Fawn.Runtime.DropdownScroll="fractional visual interpolation with dedicated gutter and smooth thumb drag"
Fawn.Runtime.AccessoryPopup="embedded-keybind three-dot popup supports custom compact controls via Control:Extra"
Fawn.Runtime.KeybindMode="right-click key field for Hold / Toggle / Always On; Backspace clears capture"
Fawn.Runtime.ContainerSeparation="stable page/section scrollbar gutters reserved during layout; wrapping uses final control width"
Fawn.Runtime.ColorPicker="compact Fawn HSV/SV + hue + alpha picker"



-- Compatibility layer: scroll-capture / wrapping / color / caret polish.
REF.SectionGap=35
REF.ColorChipFull=34
REF.ColorChipCompact=30
Fawn.Style.RowHoverDefault=false
Fawn.Style.ColumnDividersDefault=false
Fawn.Style.ColorChipSize=REF.ColorChipFull
Fawn.Rules.ScrollbarDragNeverReturnsBooleanGeometry=true
Fawn.Rules.ScaleReflowResetsCaretGeometry=true
Fawn.Rules.ColumnDividersOptIn=true

function Section:SetColumnDividers(v)self.columnDividers=v==true;return self end
function Section:GetColumnDividers()return self.columnDividers==true end
function Control:SetRowHover(v)self.rowHover=v==true;return self end
function Control:GetRowHover()return self.rowHover==true end

-- Insets strokes by half their thickness so rounded outlines remain inside their authored bounds.
function Window:_out(x,y,w,h,r,t,c,a)
    local stroke=max(.75,(tonumber(t)or self.borderThickness or 1)*(self.outlineStrength or 1))
    local inset=stroke*.5
    outline(x+inset,y+inset,max(1,w-stroke),max(1,h-stroke),c or self.outlineColor or self:_color("outline"),max(0,(r or 0)-inset),a or alphaFor(self,"outline",255),stroke)
end

-- Caret viewport is cursor-centric. Rescaling can change the visible substring without breaking the caret position.
function Window:_visibleInputText(c,fw,F)
    local raw=tostring(c.value or"")
    local masked=c.password and string.rep("*",#raw)or raw
    local ed=self.inputEdit and self.inputEdit.control==c and self.inputEdit or nil
    local cursor=ed and clamp(ed.cursor or#raw,0,#raw)or#raw
    local fontSize=renderedFontSize(F.ddFont*self.scale)
    local maxW=max(8,fw-(F.ddPadL+F.ddPadR)*self.scale)
    local start=1
    while start<=cursor and measure(sub(masked,start,cursor),fontSize,"Verdana")>maxW-2*self.scale do start=start+1 end
    local finish=#masked
    while finish>=start and measure(sub(masked,start,finish),fontSize,"Verdana")>maxW do finish=finish-1 end
    if finish<cursor then finish=cursor end
    local shown=sub(masked,start,finish)
    local caret=ed and measure(sub(masked,start,cursor),fontSize,"Verdana")or 0
    return shown,caret,start
end

-- Responsive wrapping uses the same final field split that the renderer uses.
function Window:_controlHeight(c,w,F)
    local s=self.scale
    if c.type=="spacer"then return c.height*s end
    if c.type=="separator"then return 42*s end
    local base=F.rowH*s
    if c.type=="label"then
        local maxW=max(10,w-(F.padL+F.padR)*s)
        local lines=wrapText(c.label,maxW,(c.fontSize or F.font)*s,"Verdana",c.maxLines)
        return max(48*s,#lines*(c.lineHeight or 19)*s+24*s)
    end
    if c.type=="button"then
        local maxW=max(10,w-(F.padL+F.padR+24)*s);local lines=wrapText(c.label,maxW,17*s,"Verdana",c.maxLines or 3)
        return max(base,#lines*19*s+24*s)
    end
    if c.type=="buttonpair"then
        local half=(w-(F.padL+F.padR+8)*s)/2;local l=wrapText(c.leftText,max(10,half-18*s),17*s,"Verdana",3);local r=wrapText(c.rightText,max(10,half-18*s),17*s,"Verdana",3)
        return max(base,max(#l,#r)*19*s+24*s)
    end
    if c.wrap and c.label~=""then
        local inner=max(10,w-(F.padL+F.padR)*s)
        local reserve=min(ctrlRightReserve(c,F)*s,inner*.60)
        local maxW=max(10,inner-reserve-10*s)
        local lines=wrapText(c.label,maxW,(c.fontSize or F.font)*s,"Verdana",c.maxLines or 4)
        return max(base,#lines*(c.lineHeight or 19)*s+24*s)
    end
    return base
end

-- Smaller, cleaner Fawn color chips. Alpha blends over the control surface instead of checker tiles cutting the rounded outline.
function Window:_drawColorChip(c,right,cy,F,interactive)
    local s=self.scale;local nominal=(F==REF.Compact)and REF.ColorChipCompact or REF.ColorChipFull;local sz=min(F.sw,nominal)*s
    local x=right-sz;local y=cy-sz*.5;local rad=min(8*s,sz*.24)
    self:_fill("control",x,y,sz,sz,"control",rad)
    rect(x+1*s,y+1*s,sz-2*s,sz-2*s,c.value,max(1,rad-1*s),c.value[4]or 255)
    self:_out(x,y,sz,sz,rad,.9,self:_color("outline"),220)
    if interactive and not self._consumed then
        if Input.click and not self:_hasPopup()and self:_hit(x,y,sz,sz)then self.colorPopup={control=c,x=x+sz-232*s,y=y+sz+6*s,w=232*s,h=238*s};self:_consume()
        elseif Input.rightClick and not self:_hasPopup()and self:_hit(x,y,sz,sz)then self.colorMenu={control=c,x=Input.mx,y=Input.my,w=154*s,h=84*s};self:_consume()end
    end
    return x,y,sz,sz
end

function Window:_drawColorPopup()
    local p=self.colorPopup;if not p then return end;local c=p.control;if not alive(c)then self.colorPopup=nil return end
    local s=self.scale;p.w=232*s;p.h=238*s;p.anchorY=p.y-6*s;self:_clampPopup(p);self:_popupFrame(p)
    local arr=c.value;local hue,sat,val=rgbToHsv92(arr[1],arr[2],arr[3])
    local svx,svy,svw,svh=p.x+12*s,p.y+39*s,158*s,108*s
    local hx,hy,hw,hh=p.x+181*s,p.y+39*s,16*s,108*s
    local ax,ay,aw,ah=p.x+12*s,p.y+169*s,185*s,12*s
    textC(upper(c.label or"COLOR"),p.x+12*s,p.y+17*s,self:_color("text"),13*s,"Verdana")
    local cols,rows=32,22;local cw,ch=svw/cols,svh/rows
    for iy=0,rows-1 do local vv=1-iy/(rows-1);for ix=0,cols-1 do local ss=ix/(cols-1);local r,g,b=hsvToRgb92(hue,ss,vv);rect(svx+ix*cw,svy+iy*ch,cw+.7,ch+.7,{r,g,b,255},0,255)end end
    self:_out(svx-1*s,svy-1*s,svw+2*s,svh+2*s,4*s,.8,self:_color("outline"),210)
    local sx,sy=svx+sat*svw,svy+(1-val)*svh;circle(sx,sy,3.2*s,self:_color("white"),255);outline(sx-4.2*s,sy-4.2*s,8.4*s,8.4*s,self:_color("black"),4.2*s,190,max(.8,s))
    for i=0,47 do local r,g,b=hsvToRgb92(i/47,1,1);rect(hx,hy+i*(hh/48),hw,hh/48+.5,{r,g,b,255},0,255)end
    self:_out(hx-1*s,hy-1*s,hw+2*s,hh+2*s,3*s,.8,self:_color("outline"),210);rect(hx-2*s,hy+hue*hh-1*s,hw+4*s,2*s,self:_color("white"),1*s,255)
    self:_fill("control",ax,ay,aw,ah,"control",4*s)
    for xx=0,max(1,floor(aw))-1 do local aa=round(xx/max(1,floor(aw)-1)*255);rect(ax+xx,ay,1,ah,{arr[1],arr[2],arr[3],255},0,aa)end
    self:_out(ax,ay,aw,ah,4*s,.8,self:_color("outline"),210);local alphaX=ax+(arr[4]or 255)/255*aw;rect(alphaX-1*s,ay-1*s,2*s,ah+2*s,self:_color("white"),1*s,255)
    local hex=format("#%02X%02X%02X",arr[1],arr[2],arr[3]);local ap=round((arr[4]or 255)/255*100)
    local fy=p.y+199*s;self:_fill("control",p.x+12*s,fy,88*s,23*s,"control",5*s);self:_fill("control",p.x+109*s,fy,88*s,23*s,"control",5*s)
    self:_out(p.x+12*s,fy,88*s,23*s,5*s,.7,self:_color("outline"),130);self:_out(p.x+109*s,fy,88*s,23*s,5*s,.7,self:_color("outline"),130)
    local tw=measure(hex,12*s,"Verdana");textC(hex,p.x+56*s-tw*.5,fy+11.5*s,self:_color("text"),12*s,"Verdana")
    local at=tostring(ap).."%";tw=measure(at,12*s,"Verdana");textC(at,p.x+153*s-tw*.5,fy+11.5*s,self:_color("muted"),12*s,"Verdana")
    if Input.click and not self._consumed then if self:_hit(svx,svy,svw,svh)then p.drag="sv";self:_consume()elseif self:_hit(hx,hy,hw,hh)then p.drag="h";self:_consume()elseif self:_hit(ax,ay,aw,ah)then p.drag="a";self:_consume()end end
    if p.drag then if Input.left then local h0,s0,v0=rgbToHsv92(arr[1],arr[2],arr[3]);local q=copy(arr);if p.drag=="sv"then s0=clamp((Input.mx-svx)/svw,0,1);v0=1-clamp((Input.my-svy)/svh,0,1);q[1],q[2],q[3]=hsvToRgb92(h0,s0,v0)elseif p.drag=="h"then h0=clamp((Input.my-hy)/hh,0,1);q[1],q[2],q[3]=hsvToRgb92(h0,s0,v0)else q[4]=round(clamp((Input.mx-ax)/aw,0,1)*255)end;c:Set(q)else p.drag=nil end end
end

-- Stable page/section scrollbars with explicit numeric geometry.
local function scrollbarThumb95(win,x,top,height,thumb,ratio,active)
    local s=win.scale;local span=max(1,height-thumb);local y=top+span*clamp(ratio,0,1);local hover=win:_hit(x-7*s,y-4*s,14*s,thumb+8*s);local over=hover or active
    local half=over and 2*s or 1.5*s;local width=over and 4*s or 3*s
    rect(x-half, y, width, thumb, win:_color(over and"accent"or"outline"),2*s,over and 255 or 195)
    return y,span,hover
end

-- Dropdown scroll stays fractional while open; wheel, thumb, and rows all interpolate from the same visual position.
function Window:_drawDropdownPopup()
    local p=self.openDrop;if not p then return end;local c=p.control;if not alive(c)or not visibilityPass(c)then self.openDrop=nil return end;if c.optionsSource then c:RefreshOptionsSource(false)end
    local s=self.scale;local F=REF.Full;local maxRows=min(c:GetMaxVisibleOptions(),max(1,#c.options));local margin=9*s;local rowH=F.itemH*s;p.h=margin*2+maxRows*rowH;p.w=p.w or F.ctrlW*s;p.anchorY=p.y-6*s;self:_clampPopup(p);self:_popupFrame(p)
    local maxScroll=max(0,#c.options-maxRows);p.scrollTarget=clamp(p.scrollTarget or p.scroll or c.dropdownScroll or 0,0,maxScroll);p.scrollView=clamp(p.scrollView or p.scrollTarget,0,maxScroll)
    local inside=self:_hit(p.x,p.y,p.w,p.h);if inside and Input.wheel~=0 then p.scrollTarget=clamp(p.scrollTarget+Input.wheel*c:GetDropdownScrollStep()*.72,0,maxScroll)end
    if p.drag then if Input.left then local ratio=clamp((Input.my-p.drag.top-p.drag.off)/max(1,p.drag.span),0,1);p.scrollTarget=ratio*maxScroll;p.scrollView=p.scrollTarget else p.drag=nil end else p.scrollView=p.scrollView+(p.scrollTarget-p.scrollView)*min(1,dt()*18)end
    local base=floor(p.scrollView);local frac=p.scrollView-base;local listTop=p.y+margin;local listBottom=p.y+p.h-margin;local gutter=8*s;local rowW=p.w-10*s-gutter
    for n=0,maxRows do local i=base+n+1;if i>#c.options then break end;local yy=listTop+n*rowH-frac*rowH;if yy<listBottom and yy+rowH>listTop then local visT=max(yy,listTop);local visB=min(yy+rowH,listBottom);local hov=self:_hit(p.x+5*s,visT,rowW,max(0,visB-visT));local selected=c.type=="dropdown"and c.value==i or(c.type=="multiselect"and c.value[i]==true);if hov then self:_fill("control",p.x+5*s,yy,rowW,rowH,"controlHover",F.itemR*s)elseif selected then rect(p.x+5*s,yy,rowW,rowH,self:_color("accent"),F.itemR*s,24)end;local tcy=yy+rowH*.5;if tcy-F.itemFont*s*.7>=listTop and tcy+F.itemFont*s*.7<=listBottom then textC(fit(c.options[i],rowW-30*s,F.itemFont*s,"Verdana"),p.x+F.itemPad*s,tcy,self:_color(selected and"white"or"text"),F.itemFont*s,"Verdana");if selected then ICON.check(p.x+p.w-gutter-15*s,tcy,12*s,self:_color("accent"))end end;if Input.click and not self._consumed and hov then if c.type=="dropdown"then c:Set(i);self.openDrop=nil else c:ToggleOption(i)end;self:_consume()end end end
    self:_fill("popup",p.x+1*s,p.y+1*s,p.w-2*s,margin-1*s,"popup",8*s);self:_fill("popup",p.x+1*s,p.y+p.h-margin,p.w-2*s,margin-1*s,"popup",8*s);self:_out(p.x,p.y,p.w,p.h,10*s,.9,self:_color("outline"),170)
    if maxScroll>0 then local gx=p.x+p.w-gutter;local tx=gx+gutter*.5;local top=listTop;local th=listBottom-listTop;local thumb=max(20*s,th*(maxRows/#c.options));local yy,span,hover=scrollbarThumb95(self,tx,top,th,thumb,p.scrollView/maxScroll,p.drag~=nil);local trackHover=self:_hit(gx,listTop,gutter,th);if trackHover or p.drag then rect(tx-1*s,top,2*s,th,self:_color("controlHover"),1*s,110)end;if Input.click and not self._consumed and hover then p.drag={top=top,span=span,off=Input.my-yy};self:_consume()end end
    p.scroll=clamp(round(p.scrollTarget),0,maxScroll);c.dropdownScroll=p.scroll
end

Fawn.Runtime.ScrollbarFix95="numeric hover/active geometry; no boolean arithmetic during drag"
Fawn.Runtime.RowHover="off by default; widget-specific hover remains"
Fawn.Runtime.ColumnDividers="off by default; Section:SetColumnDividers(true) opt-in"
Fawn.Runtime.ColorPicker95="smaller chips + compact HSV popup + inset outlines"
Fawn.Runtime.CaretScale="cursor-centric input viewport + editor geometry reset on scale reflow"


-- Compatibility layer: input ownership / endpoint scrolling / outline finalization.
Fawn.Rules.PopupInputIsModal=true
Fawn.Rules.FrontOverlayOwnsInputBeforeWindow=true
Fawn.Rules.ScrollEndpointsSnap=true
Fawn.Rules.SectionOutlineDrawnLast=true
Fawn.Rules.FullRowTextIsNeverClickable=true

local function snapRatio96(v)
    v=clamp(tonumber(v)or 0,0,1)
    if v<=.004 then return 0 end
    if v>=.996 then return 1 end
    return v
end
local function settle96(current,target,maxv,speed,s,immediate)
    maxv=max(0,tonumber(maxv)or 0);target=clamp(tonumber(target)or 0,0,maxv);current=clamp(tonumber(current)or target,0,maxv)
    local eps=max(.18,(tonumber(s)or 1)*.32)
    if target<=eps then target=0 elseif maxv-target<=eps then target=maxv end
    if immediate then current=target else
        current=current+(target-current)*min(1,dt()*(tonumber(speed)or 18))
        if abs(target-current)<=eps then current=target end
    end
    if current<=eps then current=0 elseif maxv-current<=eps then current=maxv end
    return clamp(current,0,maxv),target
end

-- Clicking/hovering plain labels/value text never creates a row-sized interaction surface.
-- Widget-specific hit boxes below remain unchanged.
function Control:SetRowHover(v)self.rowHover=false;return self end
function Control:GetRowHover()return false end

-- All window outline strokes are inset into their authored bounds.
function Window:_out(x,y,w,h,r,t,c,a)
    local s=self.scale or 1;local stroke=max(.75,(tonumber(t)or self.borderThickness or 1)*s*(self.outlineStrength or 1));local inset=stroke*.5
    outline(x+inset,y+inset,max(1,w-stroke),max(1,h-stroke),c or self.outlineColor or self:_color("outline"),max(0,(r or 0)-inset),a or alphaFor(self,"outline",255),stroke)
end
function Overlay:_frame(x,y,w,h,header)
    local s=overlayScale(self);local win=self.window;local c=glassColor(win,"overlay",self:_theme("popup"));local rad=10*s
    rect(x,y,w,h,c,rad,alphaFor(win,"overlay",c[4]or 255))
    local stroke=max(.75,s*((win and win.borderThickness)or 1)*((win and win.outlineStrength)or 1));local inset=stroke*.5
    outline(x+inset,y+inset,max(1,w-stroke),max(1,h-stroke),(win and win.outlineColor)or self:_theme("outline"),max(0,rad-inset),185,stroke)
    if header then line(x+1*s,y+header,x+w-1*s,y+header,self:_theme("line"),1,30)end
end

-- Front overlays use their own drag capture and remain movable even while overlapping the main Window.
function Overlay:_drag(x,y,w,h,headerH)
    if self.draggable==false then self._dragState=nil;return end
    local sw,sh=screenSize()
    if self._dragState then
        if Input.left then self.x=clamp(Input.mx-self._dragState.ox,0,max(0,sw-w));self.y=clamp(Input.my-self._dragState.oy,0,max(0,sh-h));E.pointerConsumed=true
        else self._dragState=nil end
        return
    end
    if Input.click and self:_hitOverlay(x,y,w,headerH or h)then self._dragState={ox=Input.mx-x,oy=Input.my-y};E.pointerConsumed=true end
end
function ESPPreview:_render()
    if self.docked or not self.visible or self.destroyed then return end
    local s=overlayScale(self);local w=self.width*s;local h=self.height*s
    self:_drawBody(self.x,self.y,w,h,false);self:_drag(self.x,self.y,w,h,42*s)
end

-- Final Section renderer: no row splits, no implicit column split, scrollbar gutter before one final rounded outline.
function Window:_drawSection(box,bodyTop,bodyBottom,bodyLeft,bodyRight)
    local sec=box.section;local s=self.scale;local cardTop=box.cardY;local cardBottom=cardTop+box.cardH
    local clipL=max(bodyLeft or box.x,box.x);local clipR=min(bodyRight or(box.x+box.w),box.x+box.w);local clipT=max(bodyTop,cardTop);local clipB=min(bodyBottom,cardBottom)
    local fullCard=clipL==box.x and clipR==box.x+box.w and clipT==cardTop and clipB==cardBottom
    if clipB<=clipT or clipR<=clipL then return end
    self:_fill("card",clipL,clipT,clipR-clipL,clipB-clipT,"card",fullCard and 14*s or 0)
    local rows={}for c,r in pairs(box.layouts)do rows[#rows+1]={c=c,r=r}end
    sort(rows,function(a,b)if a.r.y==b.r.y then return a.r.x<b.r.x end return a.r.y<b.r.y end)
    local offset=sec.scroll or 0
    for _,q in ipairs(rows)do
        local r={x=q.r.x,y=q.r.y-offset,w=q.r.w,h=q.r.h}
        if r.y>=clipT-.25 and r.y+r.h<=clipB+.25 and r.x>=clipL-.25 and r.x+r.w<=clipR+.25 then self:_drawControl(q.c,r,clipT,clipB)end
    end
    if sec.columnDividers==true and sec.columns and sec.columns>1 and fullCard then
        local gap=(sec.controlGap or 12)*s;local usable=box.w-(((sec.sizeMode=="fixed"or sec.sizeMode=="fill"or sec.maxHeight)and REF.SectionScrollbarGutter or 0)*s);local cw=(usable-gap*(sec.columns-1))/sec.columns
        for i=1,sec.columns-1 do local x=box.x+i*cw+(i-.5)*gap;line(x,cardTop+10*s,x,cardBottom-10*s,self:_color("line"),1,12)end
    end
    if sec.maxScroll>1 then
        local gutter=REF.SectionScrollbarGutter*s;local gx=box.x+box.w-gutter;self:_fill("card",gx,clipT,gutter,clipB-clipT,"card",0)
        local tx=gx+gutter*.5;local top=clipT+8*s;local bh=max(1,clipB-clipT-16*s);local thumb=max(28*s,bh*(box.cardH/max(box.cardH,box.contentH)));local span=max(1,bh-thumb)
        sec.scroll,sec.scrollTarget=settle96(sec.scroll,sec.scrollTarget,sec.maxScroll,self.scrollSpeed,s,sec._scrollDrag~=nil or self.resizing~=nil)
        local ratio=sec.maxScroll>0 and snapRatio96((sec.scroll or 0)/sec.maxScroll)or 0;local ty=top+span*ratio
        local trackHover=self:_hit(gx,clipT,gutter,clipB-clipT);local thumbHover=self:_hit(gx,ty-3*s,gutter,thumb+6*s);local active=sec._scrollDrag~=nil
        if trackHover or active then rect(tx-1*s,top,2*s,bh,self:_color("controlHover"),1*s,105)end
        rect(tx-((active or thumbHover)and 2*s or 1.5*s),ty,(active or thumbHover)and 4*s or 3*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 190)
        if Input.click and not self._consumed and not self:_hasPopup()and thumbHover then sec._scrollDrag={top=top,span=span,off=Input.my-ty};self:_consume()end
        if sec._scrollDrag then
            if Input.left then local rr=snapRatio96((Input.my-sec._scrollDrag.top-sec._scrollDrag.off)/max(1,sec._scrollDrag.span));sec.scrollTarget=rr*sec.maxScroll;sec.scroll=sec.scrollTarget
            else sec._scrollDrag=nil;sec.scroll,sec.scrollTarget=settle96(sec.scroll,sec.scrollTarget,sec.maxScroll,self.scrollSpeed,s,false)end
        end
    else sec._scrollDrag=nil;sec.scroll,sec.scrollTarget=0,0 end
    if fullCard then self:_out(box.x,cardTop,box.w,box.cardH,14*s,.82,self:_color("outline"),125)end
    local titleY=box.y+7*s
    if titleY>=bodyTop-20*s and titleY<=bodyBottom and box.x>=bodyLeft-1 and box.x<=(bodyRight or box.x+box.w)then textC(fit(upper(sec.name),max(20,box.w-44*s),14*s,"Verdana"),box.x+22*s,titleY,self:_color("muted"),14*s,"Verdana")end
end

-- Page scrollbar endpoint snapping prevents end-stop vibration and keeps the thumb exactly on the authored end cap.
local drawContent95=Window._drawContent
function Window:_drawContent()
    drawContent95(self)
    local tab=self:_activeTab();local layout=self._layout;if not tab or not layout then return end
    local s=self.scale
    tab.pageScroll,tab.pageTarget=settle96(tab.pageScroll,tab.pageTarget,tab.maxScroll,self.scrollSpeed,s,tab._pageDrag~=nil or self.resizing~=nil)
    if tab._pageDrag and Input.left then
        local top=layout.bodyY+4*s;local th=max(20*s,layout.bodyH-8*s);local thumb=max(32*s,th*(layout.bodyH/max(layout.bodyH,layout.contentH)));local span=max(1,th-thumb)
        tab._pageDrag.top=top;tab._pageDrag.span=span;local rr=snapRatio96((Input.my-top-tab._pageDrag.off)/span);tab.pageTarget=rr*tab.maxScroll;tab.pageScroll=tab.pageTarget
    end
end

-- Dropdowns are modal. Wheel easing stays smooth; thumb dragging snaps cleanly at both ends without bouncing.
function Window:_drawDropdownPopup()
    local p=self.openDrop;if not p then return end;local c=p.control;if not alive(c)or not visibilityPass(c)then self.openDrop=nil return end;if c.optionsSource then c:RefreshOptionsSource(false)end
    local s=self.scale;local F=REF.Full;local maxRows=min(c:GetMaxVisibleOptions(),max(1,#c.options));local margin=9*s;local rowH=F.itemH*s
    p.h=margin*2+maxRows*rowH;p.w=p.w or F.ctrlW*s;p.anchorY=p.y-6*s;self:_clampPopup(p);self:_popupFrame(p)
    local maxScroll=max(0,#c.options-maxRows);p.scrollTarget=clamp(p.scrollTarget or p.scroll or c.dropdownScroll or 0,0,maxScroll);p.scrollView=clamp(p.scrollView or p.scrollTarget,0,maxScroll)
    local inside=self:_hit(p.x,p.y,p.w,p.h)
    if inside and Input.wheel~=0 then p.scrollTarget=clamp(p.scrollTarget+Input.wheel*c:GetDropdownScrollStep()*.62,0,maxScroll)end
    if p.drag then
        if Input.left then local rr=snapRatio96((Input.my-p.drag.top-p.drag.off)/max(1,p.drag.span));p.scrollTarget=rr*maxScroll;p.scrollView=p.scrollTarget
        else p.drag=nil;p.scrollView,p.scrollTarget=settle96(p.scrollView,p.scrollTarget,maxScroll,20,s,false)end
    else p.scrollView,p.scrollTarget=settle96(p.scrollView,p.scrollTarget,maxScroll,20,s,false)end
    local base=floor(p.scrollView);local frac=p.scrollView-base;local listTop=p.y+margin;local listBottom=p.y+p.h-margin;local gutter=9*s;local rowW=p.w-10*s-gutter
    for n=0,maxRows do
        local i=base+n+1;if i>#c.options then break end;local yy=listTop+n*rowH-frac*rowH
        if yy<listBottom and yy+rowH>listTop then
            local vt=max(yy,listTop);local vb=min(yy+rowH,listBottom);local hov=self:_hit(p.x+5*s,vt,rowW,max(0,vb-vt));local selected=c.type=="dropdown"and c.value==i or(c.type=="multiselect"and c.value[i]==true)
            if hov then self:_fill("control",p.x+5*s,yy,rowW,rowH,"controlHover",F.itemR*s)elseif selected then rect(p.x+5*s,yy,rowW,rowH,self:_color("accent"),F.itemR*s,24)end
            local tcy=yy+rowH*.5;if tcy-F.itemFont*s*.7>=listTop and tcy+F.itemFont*s*.7<=listBottom then textC(fit(c.options[i],rowW-32*s,F.itemFont*s,"Verdana"),p.x+F.itemPad*s,tcy,self:_color(selected and"white"or"text"),F.itemFont*s,"Verdana");if selected then ICON.check(p.x+p.w-gutter-15*s,tcy,12*s,self:_color("accent"))end end
            if Input.click and not self._consumed and hov then if c.type=="dropdown"then c:Set(i);self.openDrop=nil else c:ToggleOption(i)end;self:_consume()end
        end
    end
    self:_fill("popup",p.x+1*s,p.y+1*s,p.w-2*s,margin-1*s,"popup",8*s);self:_fill("popup",p.x+1*s,p.y+p.h-margin,p.w-2*s,margin-1*s,"popup",8*s)
    if maxScroll>0 then
        local gx=p.x+p.w-gutter;local tx=gx+gutter*.5;local top=listTop;local th=listBottom-listTop;local thumb=max(20*s,th*(maxRows/#c.options));local span=max(1,th-thumb);local rr=maxScroll>0 and snapRatio96(p.scrollView/maxScroll)or 0;local yy=top+span*rr
        local trackHover=self:_hit(gx,listTop,gutter,th);local thumbHover=self:_hit(gx,yy-3*s,gutter,thumb+6*s);local active=p.drag~=nil
        if trackHover or active then rect(tx-1*s,top,2*s,th,self:_color("controlHover"),1*s,105)end
        rect(tx-((active or thumbHover)and 2*s or 1.5*s),yy,(active or thumbHover)and 4*s or 3*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 195)
        if Input.click and not self._consumed and thumbHover then p.drag={top=top,span=span,off=Input.my-yy};self:_consume()end
    end
    self:_out(p.x,p.y,p.w,p.h,10*s,.9,self:_color("outline"),180)
    p.scroll=clamp(round(p.scrollTarget),0,maxScroll);c.dropdownScroll=p.scroll
    if (Input.click or Input.rightClick)and inside and not self._consumed then self:_consume()end
end

-- Sidebar scrollbar uses the same endpoint snapping policy.
local sidebar95=Window._drawSidebar
function Window:_drawSidebar()
    sidebar95(self)
    local s=self.scale;local navTop,profileY=self:_sidebarGeometry();local available=max(80*s,profileY-navTop-18*s)
    local groups={};local order={};for _,t in ipairs(self:_visibleTabs())do local g=t.group or"MAIN";if not groups[g]then groups[g]={};order[#order+1]=g end;groups[g][#groups[g]+1]=t end
    local contentH=0;for _,g in ipairs(order)do contentH=contentH+26*s+#groups[g]*60*s+29*s end;local maxScroll=max(0,contentH-available)
    self.sidebarScroll,self.sidebarTarget=settle96(self.sidebarScroll,self.sidebarTarget,maxScroll,self.scrollSpeed,s,self._sidebarDrag~=nil)
    if self._sidebarDrag and Input.left then local rr=snapRatio96((Input.my-self._sidebarDrag.top-self._sidebarDrag.off)/max(1,self._sidebarDrag.span));self.sidebarTarget=rr*maxScroll;self.sidebarScroll=self.sidebarTarget end
end

-- Global pointer ownership mirrors original Fawn: active drag > modal popup > front overlay > top window > back overlay.
local function pointInWindow96(w)
    return alive(w)and w.visible~=false and Input.mx>=w.x and Input.mx<w.x+w.width*w.scale and Input.my>=w.y and Input.my<w.y+w.height*w.scale
end
local function pointInOverlay96(o)
    if not alive(o)or o.visible==false or(o.kind=="ESPPreview"and o.docked)then return false end
    local s=overlayScale(o);return Input.mx>=o.x and Input.mx<o.x+(o.width or 0)*s and Input.my>=o.y and Input.my<o.y+(o.height or 0)*s
end
local function windowActiveCapture96(w)
    if not alive(w)then return false end
    if w.dragging or w.resizing or w.activeSlider or w._sidebarDrag then return true end
    local tab=w.activeTab;if tab and tab._pageDrag then return true end
    if w.openDrop and w.openDrop.drag then return true end
    if w.colorPopup and w.colorPopup.drag then return true end
    for _,t in ipairs(w.tabs or{})do for _,sec in ipairs(t.sections or{})do if sec._scrollDrag then return true end end end
    return false
end
local function hasModal96(w)return alive(w)and w.visible~=false and w:_hasPopup()end
local function moveWindowTop96(w)removeValue(E.windows,w);E.windows[#E.windows+1]=w end
local function moveOverlayTop96(o)removeValue(E.overlays,o);E.overlays[#E.overlays+1]=o end

Fawn.Runtime.Scrollbar96="endpoint snap + stable target/view + no end-stop jitter"
Fawn.Runtime.PointerOwnership="active capture > modal popup > front overlay > top window > back overlay"
Fawn.Runtime.OverlayDrag96="front overlays regain original Fawn input priority and screen-clamped dragging"
Fawn.Runtime.ClickThrough96="dropdown/accessory/color/config/group/account popups are modal and block underlying windows/overlays"
Fawn.Runtime.Outline96="Section and overlay outlines are inset and drawn after internal fills/scrollbars"
Fawn.Runtime.RowHotspot96="plain text/value/label rows have no full-row hover or click hotspot"

-- Compatibility layer: hotkeys / modal pointer routing / scroll locking.
Fawn.Rules.OriginalFawnKeybindCapture=true
Fawn.Rules.PopupOwnsAllPointerState=true
Fawn.Rules.ExactWidgetHitboxes=true
Fawn.Rules.ScrollDragAppliedBeforeLayout=true
Fawn.Rules.OverlayDragCapturePersistsOutsideBounds=true
Fawn.Rules.OverlayDragStateNeverShadowsDragMethod=true

local KEY_ALIAS97={
    space="Space",backspace="Backspace",back="Backspace",enter="Enter",returnkey="Enter",escape="Escape",esc="Escape",tab="Tab",
    shift="Shift",leftshift="LeftShift",lshift="LeftShift",rightshift="RightShift",rshift="RightShift",
    ctrl="Ctrl",control="Ctrl",leftctrl="LeftCtrl",lctrl="LeftCtrl",rightctrl="RightCtrl",rctrl="RightCtrl",
    alt="Alt",leftalt="LeftAlt",lalt="LeftAlt",rightalt="RightAlt",ralt="RightAlt",
    insert="Insert",ins="Insert",delete="Delete",del="Delete",home="Home",["end"]="End",up="Up",down="Down",left="Left",right="Right",
    pageup="PageUp",pgup="PageUp",pagedown="PageDown",pgdn="PageDown",
    mouse1="Mouse1",m1="Mouse1",lmb="Mouse1",mouse2="Mouse2",m2="Mouse2",rmb="Mouse2",mouse3="Mouse3",m3="Mouse3",mmb="Mouse3",mouse4="Mouse4",m4="Mouse4",mouse5="Mouse5",m5="Mouse5"
}
local VK97={
    [1]="Mouse1",[2]="Mouse2",[4]="Mouse3",[5]="Mouse4",[6]="Mouse5",[8]="Backspace",[9]="Tab",[13]="Enter",[16]="Shift",[17]="Ctrl",[18]="Alt",[27]="Escape",[32]="Space",
    [33]="PageUp",[34]="PageDown",[35]="End",[36]="Home",[37]="Left",[38]="Up",[39]="Right",[40]="Down",[45]="Insert",[46]="Delete",
    [160]="LeftShift",[161]="RightShift",[162]="LeftCtrl",[163]="RightCtrl",[164]="LeftAlt",[165]="RightAlt"
}
local VK_NAME97={LeftShift=160,RightShift=161,LeftCtrl=162,RightCtrl=163,LeftAlt=164,RightAlt=165,PageUp=33,PageDown=34}
local function canonicalKey97(k)
    if k==nil or k==""then return nil end
    if type(k)=="number"then
        if VK97[k]then return VK97[k]end
        if k>=48 and k<=57 then return string.char(k)end
        if k>=65 and k<=90 then return string.char(k)end
        if k>=112 and k<=123 then return"F"..tostring(k-111)end
        return k
    end
    local q=tostring(k);if #q==1 then return upper(q)end
    local compact=lower(q):gsub("[%s_%-]","")
    local alias=KEY_ALIAS97[compact];if alias then return alias end
    local fn=compact:match("^f(%d+)$");if fn then local n=tonumber(fn);if n and n>=1 and n<=12 then return"F"..n end end
    return q
end
local function keyLabel97(k)
    local q=canonicalKey97(k);if q==nil then return"None"end
    local labels={LeftShift="LEFT SHIFT",RightShift="RIGHT SHIFT",LeftCtrl="LEFT CTRL",RightCtrl="RIGHT CTRL",LeftAlt="LEFT ALT",RightAlt="RIGHT ALT",PageUp="PAGE UP",PageDown="PAGE DOWN"}
    return labels[q]or upper(tostring(q))
end
local function keyDown97(k)
    local q=canonicalKey97(k);if q==nil then return false end
    if type(q)=="number"then return keyState(q)end
    local vk=VK_NAME97[q];if vk then return keyState(vk)end
    return nativeKey(q)
end

local setKeyBase97=Control.SetKey
function Control:SetKey(key,label)
    local k=self.type=="keybind"and self or self.keybind;if not k then return self end
    local q=canonicalKey97(key);k.key=q;k.keyLabel=label or keyLabel97(q);k.active=k.mode=="Always";k.last=false
    if k.onKeyChanged then pcall(k.onKeyChanged,k.key,k.keyLabel,k)end
    return self
end
function Control:SetMode(mode)
    local k=self.type=="keybind"and self or self.keybind;if not k then return self end
    mode=tostring(mode or"");if mode=="Always On"then mode="Always"end;if mode~="Hold"and mode~="Toggle"and mode~="Always"then return self end
    local old=k.active;k.mode=mode;k.active=mode=="Always";k.last=false
    if old~=k.active and k.callback then pcall(k.callback,k.active,k)end
    return self
end
local setKeybindBase97=Control.SetKeybind
function Control:SetKeybind(key,opt)
    opt=type(opt)=="table"and opt or{};setKeybindBase97(self,key,opt)
    if self.keybind then self.keybind:SetKey(key,opt.label);if opt.mode then self.keybind:SetMode(opt.mode)end end
    return self
end
local sectionKeybindBase97=Section.Keybind
function Section:Keybind(label,key,opt)
    opt=type(opt)=="table"and opt or{};local c=sectionKeybindBase97(self,label,key,opt);c:SetKey(key,opt.label);if opt.mode then c:SetMode(opt.mode)end;return c
end
Section.AddKeybind=Section.Keybind;Section.Hotkey=Section.Keybind
local setToggleKeyBase97=Window.SetToggleKey
function Window:SetToggleKey(key,label)
    local q=canonicalKey97(key);self.toggleKey=q;self.toggleLabel=label or keyLabel97(q);self._toggleLast97=false;self._toggleKeyIdentity97=q;return self
end
-- A late compatibility alias in older Modern builds accidentally replaced Window:Toggle() with AddToggle().
-- Restore the original Fawn meaning: Window:Toggle() only changes window visibility.
function Window:Toggle()return self:SetVisible(not self.visible)end

local function eachKeybind97(self,fn)
    self:ForEachControl(function(c)
        if c.type=="keybind"then fn(c)end
        if c.keybind then fn(c.keybind)end
    end)
end
function Window:_processKeybinds()
    eachKeybind97(self,function(k)
        if not alive(k)then return end
        local down=k.key~=nil and keyDown97(k.key)or false;local old=k.active
        if k.mode=="Always"then k.active=true elseif k.mode=="Hold"then k.active=down elseif k.mode=="Toggle"then if down and not k.last then k.active=not k.active end end
        k.last=down
        if old~=k.active and k.callback then pcall(k.callback,k.active,k)end
    end)
end
Window._updateKeybinds=Window._processKeybinds

function Window:_processBindCapture()
    local c=self.captureBind
    if not c then self._captureControl97=nil;self._captureArmed97=nil;return end
    if not alive(c)then self.captureBind=nil;self._captureControl97=nil;self._captureArmed97=nil;return end
    if self._captureControl97~=c then self._captureControl97=c;self._captureArmed97=false end
    if not self._captureArmed97 then
        if Input.left or Input.right or keyState(4)or keyState(5)or keyState(6)then return end
        self._captureArmed97=true;return
    end
    if Input.pressed.Escape then self.captureBind=nil;self._captureControl97=nil;self._captureArmed97=nil;return end
    if Input.pressed.Backspace then c:ClearKey();self.captureBind=nil;self._captureControl97=nil;self._captureArmed97=nil;return end
    if not c.keyboardOnly then
        for _,name in ipairs{"Mouse1","Mouse2","Mouse3","Mouse4","Mouse5"}do if Input.pressed[name]then c:SetKey(name,keyLabel97(name));if c==self.toggleControl then self._toggleSuppress97=name end;self.captureBind=nil;self._captureControl97=nil;self._captureArmed97=nil;return end end
    end
    for _,name in ipairs(POLL)do
        if sub(name,1,5)~="Mouse"and name~="Escape"and name~="Backspace"and Input.pressed[name]then
            c:SetKey(name,keyLabel97(name));if c==self.toggleControl then self._toggleSuppress97=canonicalKey97(name)end;self.captureBind=nil;self._captureControl97=nil;self._captureArmed97=nil;return
        end
    end
end

function Window:_toggleByKey()
    local k=(self.toggleControl and self.toggleControl.type=="keybind")and self.toggleControl.key or self.toggleKey;k=canonicalKey97(k)
    if not k then self._toggleLast97=false;self._toggleKeyIdentity97=nil;return end
    if self._toggleKeyIdentity97~=k then self._toggleKeyIdentity97=k;self._toggleLast97=keyDown97(k)end
    local down=keyDown97(k)
    if self.captureBind or self.inputEdit or self.sliderEdit or self.searchOpen then self._toggleLast97=down;return end
    if self._toggleSuppress97 then if keyDown97(self._toggleSuppress97)then self._toggleLast97=down;return else self._toggleSuppress97=nil;self._toggleLast97=false end end
    if down and not self._toggleLast97 then self:Toggle()end
    self._toggleLast97=down
end

-- Cleared binds disappear from automatic/tracked keybind lists, matching original Fawn.
function KeybindList:_entries()
    local out={}
    local function add(c,name,tracked)
        if not alive(c)then return end;local k=c.type=="keybind"and c or c.keybind
        if not k or k.keybindList==false or k.key==nil or k.key==""then return end
        if self.onlyActive and not k.active then return end
        out[#out+1]={name=name or c.label or"Keybind",key=k}
    end
    for c,name in pairs(self.tracked)do add(c,name,true)end
    if self.auto and self.window then self.window:ForEachControl(function(c)if not self.tracked[c]then add(c,c.label,false)end end)end
    sort(out,function(a,b)return tostring(a.name)<tostring(b.name)end);return out
end

-- Search and any popup are modal for pointer routing. Key capture is an active input capture, not a popup.
function Window:_hasPopup()return self.openDrop or self.extraPopup or self.keyMenu or self.colorPopup or self.colorMenu or self.configPopup or self.groupPopup or self.accountOpen or self.searchOpen end
local function hasModal97(w)return alive(w)and w.visible~=false and w:_hasPopup()end
local function windowActiveCapture97(w)
    if not alive(w)then return false end
    if w.captureBind or w.dragging or w.resizing or w.activeSlider or w._sidebarDrag then return true end
    local tab=w.activeTab
    if tab then
        if tab._pageDrag then return true end
        local dp=tab.dockedPreview
        if alive(dp)and(dp._espDrag or dp._dragElement)then return true end
    end
    if w.openDrop and w.openDrop.drag then return true end;if w.colorPopup and w.colorPopup.drag then return true end
    for _,t in ipairs(w.tabs or{})do for _,sec in ipairs(t.sections or{})do if sec._scrollDrag then return true end end end
    return false
end

-- Never paint a row-sized hover surface. Only the authored widget rectangles react visually/click.
local drawControlBase97=Window._drawControl
function Window:_drawControl(c,r,clipTop,clipBottom)
    c.rowHover=false
    local prev=self._activeControlAnimId
    self._activeControlAnimId=c and c.id or prev
    local a,b,d,e=drawControlBase97(self,c,r,clipTop,clipBottom)
    self._activeControlAnimId=prev
    return a,b,d,e
end

-- Stable page layout: content height is computed in unscrolled coordinates, so maxScroll never changes just because the page moved.
function Window:_buildLayout(tab)
    local s=self.scale;local panel=self.kind=="Panel"or self.tabBarVisible==false
    local bodyX=panel and(self.x+18*s)or self:_sx(REF.ContentX);local bodyY=panel and(self.y+72*s)or self:_sy(REF.ContentTop)
    local rawBodyW=max(1,panel and((self.width-36)*s)or((self.width-REF.ContentX-REF.RightMargin)*s));local fullBodyH=max(1,panel and((self.height-90)*s)or((self.height-REF.ContentTop-15)*s))
    local pageGutter=REF.PageScrollbarGutter*s;local usableBodyW=max(40*s,rawBodyW-pageGutter);local bodyW,bodyH=usableBodyW,fullBodyH;local preview=nil;local cols=clamp(self.columns,1,4);local gap=REF.ColumnGap*s
    if tab and alive(tab.dockedPreview)and tab.dockedPreview.visible~=false and tab.dockedPreview.docked~=false then
        local dp=tab.dockedPreview;local pgap=(dp.dockGap or REF.ColumnGap)*s;local desired=clamp(usableBodyW*(dp.dockWidthRatio or .36),220*s,440*s);local minContent=max(260*s,cols*235*s+gap*(cols-1));local mode=dp.dockMode or"auto";local sideOK=(usableBodyW-desired-pgap)>=minContent
        if mode=="side"or(mode=="auto"and sideOK)then local pw=min(desired,max(180*s,usableBodyW-minContent-pgap));bodyW=max(1,usableBodyW-pw-pgap);preview={x=bodyX+bodyW+pgap,y=bodyY,w=pw,h=fullBodyH,mode="side"}
        else local ph=clamp(fullBodyH*(dp.dockHeightRatio or .38),190*s,340*s);bodyH=max(120*s,fullBodyH-ph-pgap);preview={x=bodyX,y=bodyY+bodyH+pgap,w=usableBodyW,h=min(ph,fullBodyH-bodyH-pgap),mode="bottom"}end
    end
    local colW=max(40*s,(bodyW-gap*(cols-1))/cols);local rowsMap={};for _,sec in ipairs(tab.sections)do if alive(sec)and visibilityPass(sec)then local row=max(1,floor(sec.row or 1));rowsMap[row]=rowsMap[row]or{};rowsMap[row][#rowsMap[row]+1]=sec end end
    local rowNums={}for r in pairs(rowsMap)do rowNums[#rowNums+1]=r end;sort(rowNums)
    local sections={};local logicalY=bodyY;local contentBottom=bodyY
    for _,row in ipairs(rowNums)do
        local rowSecs=rowsMap[row];local rowH=0;local pre={}
        for _,sec in ipairs(rowSecs)do
            local col=clamp(floor(sec.column or 1),1,cols);local span=clamp(floor(sec.span or 1),1,cols-col+1);local x=bodyX+(col-1)*(colW+gap);local w=max(40*s,colW*span+gap*(span-1));local layouts,controlH=self:_sectionControlLayout(sec,x,logicalY+30*s,w);local total
            if sec.sizeMode=="fixed"then total=max(30*s+63*s,(tonumber(sec.height)or 240)*s)elseif sec.sizeMode=="fill"then total=max(30*s+63*s,bodyY+bodyH-logicalY)else total=30*s+controlH end
            if sec.minHeight then total=max(total,sec.minHeight*s)end;if sec.maxHeight then total=min(total,sec.maxHeight*s)end
            pre[#pre+1]={sec=sec,x=x,w=w,layouts=layouts,contentH=controlH,total=total};rowH=max(rowH,total)
        end
        for _,q in ipairs(pre)do
            local sec=q.sec;local total=q.total;if sec.sizeMode=="fill"then total=rowH end;local cardY=logicalY+30*s;local cardH=max(1,total-30*s)
            sec.maxScroll=sectionInternalScroll92(sec,q.contentH,cardH);sec.scrollTarget=clamp(sec.scrollTarget or 0,0,sec.maxScroll);sec.scroll,sec.scrollTarget=settle96(sec.scroll,sec.scrollTarget,sec.maxScroll,self.scrollSpeed,s,self.resizing~=nil or sec._scrollDrag~=nil or self.smoothScroll==false);sec.resolvedHeight=total/s
            sections[#sections+1]={section=sec,x=q.x,y=logicalY,w=q.w,h=total,cardY=cardY,cardH=cardH,layouts=q.layouts,contentH=q.contentH};contentBottom=max(contentBottom,logicalY+total)
        end
        logicalY=logicalY+rowH+REF.SectionGap*s;contentBottom=max(contentBottom,logicalY)
    end
    local contentH=max(0,contentBottom-bodyY-(#rowNums>0 and REF.SectionGap*s or 0));tab.maxScroll=max(0,contentH-bodyH)
    if self.mainScrollEnabled~=false and tab.mainScrollEnabled~=false then tab.pageTarget=clamp(tab.pageTarget or 0,0,tab.maxScroll)else tab.pageTarget=0 end
    tab.pageScroll,tab.pageTarget=settle96(tab.pageScroll,tab.pageTarget,tab.maxScroll,self.scrollSpeed,s,self.resizing~=nil or tab._pageDrag~=nil or self.smoothScroll==false)
    local scroll=tab.pageScroll or 0
    if scroll~=0 then for _,box in ipairs(sections)do box.y=box.y-scroll;box.cardY=box.cardY-scroll;for _,r in pairs(box.layouts)do r.y=r.y-scroll end end end
    self._layout={bodyX=bodyX,bodyY=bodyY,bodyW=bodyW,fullBodyW=rawBodyW,usableBodyW=usableBodyW,pageGutter=pageGutter,bodyH=bodyH,fullBodyH=fullBodyH,sections=sections,contentH=contentH,maxScroll=tab.maxScroll,preview=preview};return self._layout
end

-- Final Section renderer updates drag state before row positions are consumed.
function Window:_drawSection(box,bodyTop,bodyBottom,bodyLeft,bodyRight)
    local sec=box.section;local s=self.scale;local cardTop=box.cardY;local cardBottom=cardTop+box.cardH;local clipL=max(bodyLeft or box.x,box.x);local clipR=min(bodyRight or(box.x+box.w),box.x+box.w);local clipT=max(bodyTop,cardTop);local clipB=min(bodyBottom,cardBottom);local fullCard=abs(clipL-box.x)<.25 and abs(clipR-(box.x+box.w))<.25 and abs(clipT-cardTop)<.25 and abs(clipB-cardBottom)<.25
    if clipB<=clipT or clipR<=clipL then return end
    if sec._scrollDrag then
        if Input.left and sec.maxScroll>0 then local rr=snapRatio96((Input.my-sec._scrollDrag.top-sec._scrollDrag.off)/max(1,sec._scrollDrag.span));sec.scrollTarget=rr*sec.maxScroll;sec.scroll=sec.scrollTarget else sec._scrollDrag=nil;sec.scroll,sec.scrollTarget=settle96(sec.scroll,sec.scrollTarget,sec.maxScroll,self.scrollSpeed,s,false)end
    else sec.scroll,sec.scrollTarget=settle96(sec.scroll,sec.scrollTarget,sec.maxScroll,self.scrollSpeed,s,false)end
    self:_fill("card",clipL,clipT,clipR-clipL,clipB-clipT,"card",fullCard and 14*s or 0)
    local rows={}for c,r in pairs(box.layouts)do rows[#rows+1]={c=c,r=r}end;sort(rows,function(a,b)if a.r.y==b.r.y then return a.r.x<b.r.x end return a.r.y<b.r.y end);local offset=sec.scroll or 0
    for _,q in ipairs(rows)do local r={x=q.r.x,y=q.r.y-offset,w=q.r.w,h=q.r.h};if r.y>=clipT-.25 and r.y+r.h<=clipB+.25 and r.x>=clipL-.25 and r.x+r.w<=clipR+.25 then self:_drawControl(q.c,r,clipT,clipB)end end
    if sec.columnDividers==true and sec.columns and sec.columns>1 and fullCard then local gap=(sec.controlGap or 12)*s;local usable=box.w-(((sec.sizeMode=="fixed"or sec.sizeMode=="fill"or sec.maxHeight)and REF.SectionScrollbarGutter or 0)*s);local cw=(usable-gap*(sec.columns-1))/sec.columns;for i=1,sec.columns-1 do local x=box.x+i*cw+(i-.5)*gap;line(x,cardTop+8*s,x,cardBottom-8*s,self:_color("line"),1,14)end end
    if sec.maxScroll>1 then
        local gutter=REF.SectionScrollbarGutter*s;local gx=box.x+box.w-gutter;self:_fill("card",gx,clipT,gutter,clipB-clipT,"card",0);local tx=gx+gutter*.5;local top=clipT+8*s;local bh=max(1,clipB-clipT-16*s);local thumb=max(28*s,bh*(box.cardH/max(box.cardH,box.contentH)));local span=max(1,bh-thumb);local ratio=sec.maxScroll>0 and snapRatio96((sec.scroll or 0)/sec.maxScroll)or 0;local ty=top+span*ratio;local trackHover=self:_hit(gx,clipT,gutter,clipB-clipT);local thumbHover=self:_hit(gx,ty-3*s,gutter,thumb+6*s);local active=sec._scrollDrag~=nil
        if trackHover or active then rect(tx-1*s,top,2*s,bh,self:_color("controlHover"),1*s,105)end;rect(tx-((active or thumbHover)and 2*s or 1.5*s),ty,(active or thumbHover)and 4*s or 3*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 190)
        if Input.click and not self._consumed and not self:_hasPopup()and thumbHover then sec._scrollDrag={top=top,span=span,off=Input.my-ty};self:_consume()end
    else sec._scrollDrag=nil;sec.scroll,sec.scrollTarget=0,0 end
    if fullCard then self:_out(box.x,cardTop,box.w,box.cardH,14*s,.82,self:_color("outline"),125)end
    local titleY=box.y+7*s;if titleY>=bodyTop-20*s and titleY<=bodyBottom and box.x>=bodyLeft-1 and box.x<=(bodyRight or box.x+box.w)then textC(fit(upper(sec.name),max(20,box.w-44*s),14*s,"Verdana"),box.x+22*s,titleY,self:_color("muted"),14*s,"Verdana")end
end

-- Final content pass: one layout solve, one draw, one stable page scrollbar.
function Window:_drawContent()
    local s=self.scale;local tab=self:_activeTab();if not tab then return end
    if tab._pageDrag then if Input.left and tab.maxScroll>0 then local rr=snapRatio96((Input.my-tab._pageDrag.top-tab._pageDrag.off)/max(1,tab._pageDrag.span));tab.pageTarget=rr*tab.maxScroll;tab.pageScroll=tab.pageTarget else tab._pageDrag=nil end end
    local layout=self:_buildLayout(tab);local top,bottom=layout.bodyY,layout.bodyY+layout.bodyH;local left,right=layout.bodyX,layout.bodyX+layout.bodyW;local pointerBody=self:_hit(left,top,layout.bodyW,layout.bodyH);local wheelOwned=false
    for _,box in ipairs(layout.sections)do local sec=box.section;local l=max(box.x,left);local r=min(box.x+box.w,right);local ht=max(box.cardY,top);local hb=min(box.cardY+box.cardH,bottom);if sec.maxScroll>1 and r>l and hb>ht and self:_hit(l,ht,r-l,hb-ht)and Input.wheel~=0 and not self:_hasPopup()then sec:ScrollBy(Input.wheel*sec:GetScrollStep());wheelOwned=true;break end end
    if not wheelOwned and pointerBody and Input.wheel~=0 and not self:_hasPopup()and tab.maxScroll>0 then tab:ScrollBy(Input.wheel*tab:GetScrollStep())end
    for _,box in ipairs(layout.sections)do if box.y+box.h>=top and box.y<=bottom and box.x+box.w>=left and box.x<=right then self:_drawSection(box,top,bottom,left,right)end end
    if layout.preview and alive(tab.dockedPreview)then tab.dockedPreview:_renderDocked(layout.preview)end
    if #layout.sections==0 then local h=min(220*s,layout.bodyH);self:_fill("card",left,top,layout.bodyW,h,"card",14*s);self:_out(left,top,layout.bodyW,h,14*s,.8,self:_color("outline"),100);local msg="No settings on this tab yet";local tw,th=measure(msg,18*s,"Verdana");text(msg,left+(layout.bodyW-tw)*.5,top+(h-th)*.5,self:_color("muted"),18*s,"Verdana")end
    if tab.maxScroll>1 then
        local gx=layout.bodyX+layout.bodyW;local gutter=layout.pageGutter or REF.PageScrollbarGutter*s;local tx=gx+gutter*.5;local th=max(20*s,layout.bodyH-8*s);local ty=top+4*s;local thumb=max(32*s,th*(layout.bodyH/max(layout.bodyH,layout.contentH)));local span=max(1,th-thumb);local rr=snapRatio96((tab.pageScroll or 0)/tab.maxScroll);local yy=ty+span*rr;local trackHover=self:_hit(gx,top,gutter,layout.bodyH);local thumbHover=self:_hit(gx,yy-3*s,gutter,thumb+6*s);local active=tab._pageDrag~=nil
        if trackHover or active then rect(tx-1*s,ty,2*s,th,self:_color("controlHover"),1*s,120)end;rect(tx-((active or thumbHover)and 2*s or 1.5*s),yy,(active or thumbHover)and 4*s or 3*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 200)
        if Input.click and not self._consumed and not self:_hasPopup()and thumbHover then tab._pageDrag={top=ty,span=span,off=Input.my-yy};self:_consume()end
    else tab._pageDrag=nil end
end

-- Final main outline uses the same inset helper as Sections/popups instead of a separate edge calculation.
function Window:_render()
    if self.destroyed then return end
    if self._pendingScale then local q=self._pendingScale;self._pendingScale=nil;applyScale93(self,q)end
    self:_toggleByKey();self:_processKeybinds();self:_processBindCapture();self:_processInputEdit();self:_processSliderEdit()
    if not self.visible then return end

    self._inRender=true
    self._consumed=false

    -- Clicking the same normal dropdown field closes it before any underlying
    -- controls see the click.
    if self.openDrop and Input.click and not self._consumed then
        local p=self.openDrop
        if p.triggerX and p.triggerY and p.triggerW and p.triggerH and self:_hit(p.triggerX,p.triggerY,p.triggerW,p.triggerH)then
            self.openDrop=nil
            self:_consume()
        end
    end
    if self.colorPopup and Input.click and not self._consumed then
        local p=self.colorPopup
        if p.triggerX and p.triggerY and p.triggerW and p.triggerH and self:_hit(p.triggerX,p.triggerY,p.triggerW,p.triggerH)then
            self.colorPopup=nil
            self:_consume()
        end
    end

    -- Never begin a new window drag/resize through a popup.
    if not self:_hasPopup() or self.dragging or self.resizing then
        self:_updateWindowDragResize()
    end

    local s=self.scale
    local X,Y=self.x,self.y
    local W,H=self.width*s,self.height*s

    if (Input.click or Input.rightClick)and not self._consumed and self:_hasPopup()then
        local inside=false
        for _,p in pairs({self.openDrop,self.extraPopup,self.keyMenu,self.colorPopup,self.colorMenu,self.configPopup,self.groupPopup})do
            if p then
                if p.x and p.y and p.w and p.h and self:_hit(p.x,p.y,p.w,p.h)then inside=true break end
                if p.triggerX and p.triggerY and p.triggerW and p.triggerH and self:_hit(p.triggerX,p.triggerY,p.triggerW,p.triggerH)then inside=true break end
                local ch=p.child
                if ch and ch.x and ch.y and ch.w and ch.h and self:_hit(ch.x,ch.y,ch.w,ch.h)then inside=true break end
            end
        end
        if self.accountOpen then
            local _,py=self:_sidebarGeometry()
            if self:_hit(X+7*s,py-244*s,261*s,236*s)or self:_hit(X+15*s,py,245*s,55*s)then inside=true end
        end
        if self.searchOpen then
            local sw=310*s;local sx=X+(self.width-REF.RightMargin)*s-sw;local sy=Y+78*s
            if self:_hit(sx,sy,sw,44*s)then inside=true end
        end
        if not inside then self:_closePopups();self:_consume()end
    end

    self:_fill("main",X,Y,W,H,"menuBg",self.corner*s)
    self:_drawContent()

    local r=self.corner*s
    local modal=self:_hasPopup()

    -- Draw sidebar/topbar/panel header normally, but remove *all* pointer state
    -- while a dropdown/popup is above them. This prevents a dropdown selection
    -- from also clicking the profile row, tabs, topbar buttons, or panel header.
    local function drawChrome(fn)
        if not modal then return fn(self)end
        local click,rightClick,left,right,released,rightReleased,wheel=
            Input.click,Input.rightClick,Input.left,Input.right,Input.released,Input.rightReleased,Input.wheel
        Input.click,Input.rightClick,Input.left,Input.right,Input.released,Input.rightReleased,Input.wheel=
            false,false,false,false,false,false,0
        local ok,a,b,c,d=pcall(fn,self)
        Input.click,Input.rightClick,Input.left,Input.right,Input.released,Input.rightReleased,Input.wheel=
            click,rightClick,left,right,released,rightReleased,wheel
        if not ok then error(a)end
        return a,b,c,d
    end

    if self.kind=="Panel"or self.tabBarVisible==false then
        local topH=72*s;local botH=18*s
        maskTop93(self,X,Y,W,topH,r)
        maskBottom93(self,X,Y+H-botH,W,botH,r)
        local midY=Y+topH;local midH=max(0,H-topH-botH)
        if midH>0 then
            self:_fill("main",X,midY,18*s,midH,"menuBg",0)
            self:_fill("main",X+W-18*s,midY,18*s,midH,"menuBg",0)
        end
        drawChrome(Window._drawPanelHeader)
    else
        local topH=REF.ContentTop*s;local botH=15*s
        maskTop93(self,X,Y,W,topH,r)
        maskBottom93(self,X,Y+H-botH,W,botH,r)
        local midY=Y+topH;local midH=max(0,H-topH-botH)
        if midH>0 then
            self:_fill("main",X,midY,REF.ContentX*s,midH,"menuBg",0)
            self:_fill("main",X+W-REF.RightMargin*s,midY,REF.RightMargin*s,midH,"menuBg",0)
        end
        drawChrome(Window._drawSidebar)
        drawChrome(Window._drawTopbar)
    end

    self:_out(X,Y,W,H,r,self.borderThickness,self.outlineColor,255)

    -- Popups are always rendered after chrome with the real pointer restored.
    self:_drawExtraPopup()
    self:_drawDropdownPopup()
    self:_drawKeyMenu()
    self:_drawColorPopup()
    self:_drawColorMenu()
    self:_drawConfigPopup()
    self:_drawGroupPopup()
    self:_drawAccountPopup()
    self:_drawSearchPopup()
    self._inRender=false
end

Fawn.Runtime.Keybind97="original Fawn armed-after-release capture; canonical key names; activation callbacks; settings toggle-key suppression while editing"
Fawn.Runtime.OverlayDrag97="drag state is stored separately from Overlay:_drag method; Watermark/KeybindList/InfoPanel/standalone ESP remain draggable"
Fawn.Runtime.ModalPointer97="popup owner receives pointer; content/sidebar/topbar/panel chrome are pointer-silent under popups; covered controls cannot receive the same click"
Fawn.Runtime.ScrollEnd97="page maxScroll is computed from unscrolled content; page/Section thumb motion is applied before layout with exact endpoint snap"
Fawn.Runtime.Outline97="window/Section/popup/overlay strokes share scale-aware inset thickness; main outline is drawn once in the final pass"
Fawn.Runtime.WidgetHitboxes97="plain text rows never consume pointer input; switches/fields/buttons/pickers only"

-- Runtime registration
-- Loading Fawn again in the same Serotonin session deactivates the previous callback set.
local runtimeToken={active=true}
do
    local g=type(_G)=="table"and _G or nil
    if g then local old=rawget(g,"__FAWN_MODERN_RUNTIME");if type(old)=="table"then old.active=false end;g.__FAWN_MODERN_RUNTIME=runtimeToken end
end
local function updateEvent()
    if not runtimeToken.active then return end
    local ok,err=pcall(pollInput)
if not ok then E.lastInputError=tostring(err)end
end
local function paintEvent()
    if not runtimeToken.active then return end
    local P=Fawn.Performance;local okT,vT=pcall(utility.GetTickCount);if okT then P.FrameNow=tonumber(vT)or P.FrameNow end;local okD,vD=pcall(utility.GetDeltaTime);if okD then P.FrameDt=tonumber(vD)or P.FrameDt end;local okS,sw,sh=pcall(draw.GetScreenSize);if okS and type(sw)=="number"and type(sh)=="number"then P.ScreenW,P.ScreenH,P.ScreenReady=sw,sh,true end
    beginPaintInput();E.paintCount=E.paintCount+1;E.pointerConsumed=false
    local raw={click=Input.click,rightClick=Input.rightClick,left=Input.left,right=Input.right,released=Input.released,rightReleased=Input.rightReleased,wheel=Input.wheel}
    local function protected(fn,obj)local ok,err=pcall(fn,obj);if not ok then E.paintErrors=E.paintErrors+1;E.lastPaintError=tostring(err)end end
    local function pointer(on)
        if on then Input.click,Input.rightClick,Input.left,Input.right,Input.released,Input.rightReleased,Input.wheel=raw.click,raw.rightClick,raw.left,raw.right,raw.released,raw.rightReleased,raw.wheel
        else Input.click,Input.rightClick,Input.left,Input.right,Input.released,Input.rightReleased,Input.wheel=false,false,false,false,false,false,0 end
    end

    local popupOwner=nil
    for i=#E.windows,1,-1 do local w=E.windows[i];if hasModal97(w)then popupOwner=w;break end end
    local activeOverlay=nil
    if not popupOwner then for i=#E.overlays,1,-1 do local o=E.overlays[i];if alive(o)and(o._dragState or(o._espDrag and not(o.kind=="ESPPreview"and o.docked)))then activeOverlay=o;break end end end
    local activeWindow=nil
    if not popupOwner and not activeOverlay then for i=#E.windows,1,-1 do local w=E.windows[i];if windowActiveCapture97(w)then activeWindow=w;break end end end
    local frontOverlay=nil
    if not popupOwner then
        if activeOverlay and(activeOverlay.layer or"front")~="back"then frontOverlay=activeOverlay
        elseif not activeOverlay and not activeWindow then for i=#E.overlays,1,-1 do local o=E.overlays[i];if alive(o)and(o.layer or"front")~="back"and pointInOverlay96(o)then frontOverlay=o;break end end end
    end
    local windowOwner=activeWindow
    if not popupOwner and not activeOverlay and not activeWindow and not frontOverlay then for i=#E.windows,1,-1 do local w=E.windows[i];if pointInWindow96(w)then windowOwner=w;break end end end
    local backOverlay=nil
    if not popupOwner then
        if activeOverlay and(activeOverlay.layer or"front")=="back"then backOverlay=activeOverlay
        elseif not activeOverlay and not activeWindow and not frontOverlay and not windowOwner then for i=#E.overlays,1,-1 do local o=E.overlays[i];if alive(o)and(o.layer or"front")=="back"and pointInOverlay96(o)then backOverlay=o;break end end end
    end

    if raw.click then if popupOwner then moveWindowTop96(popupOwner)elseif frontOverlay then moveOverlayTop96(frontOverlay)elseif windowOwner then moveWindowTop96(windowOwner)elseif backOverlay then moveOverlayTop96(backOverlay)end end

    for _,o in ipairs(E.overlays)do if alive(o)and o.layer=="back"and not(o.kind=="ESPPreview"and o.docked)and type(o._render)=="function"then pointer(backOverlay==o and not popupOwner);protected(o._render,o)end end
    for _,w in ipairs(E.windows)do if alive(w)then local owns=popupOwner==w or(not popupOwner and not activeOverlay and not frontOverlay and windowOwner==w);pointer(owns);protected(w._render,w)end end
    for _,o in ipairs(E.overlays)do if alive(o)and o.layer~="back"and not(o.kind=="ESPPreview"and o.docked)and type(o._render)=="function"then pointer(frontOverlay==o and not popupOwner);protected(o._render,o)end end

    -- Notifications cannot be clicked through a modal popup either.
    pointer(not popupOwner and not activeOverlay and not activeWindow and not frontOverlay and not windowOwner and not backOverlay)
    local aliveNotes={};local counts={}
    for _,n in ipairs(E.notifications)do if alive(n)and not n.dismissed and nowMs()<n.expires then local pos=n.position or"Bottom Right";counts[pos]=(counts[pos]or 0)+1;local ok,shown=pcall(n._render,n,counts[pos]);if ok and shown then aliveNotes[#aliveNotes+1]=n elseif not ok then E.paintErrors=E.paintErrors+1;E.lastPaintError=tostring(shown)end end end
    E.notifications=aliveNotes;pointer(true)
end
local function registerEvent(name,fn)
    local ok,err=pcall(cheat.Register,name,fn)
return ok,err
end
local updateOK=registerEvent("onUpdate",updateEvent)
if not updateOK then updateOK=registerEvent("update",updateEvent)end
local paintOK=registerEvent("onPaint",paintEvent)
if not paintOK then paintOK=registerEvent("paint",paintEvent)end
registerEvent("shutdown",function()runtimeToken.active=false end)
if not updateOK then -- fallback keeps normal controls usable on runtimes without onUpdate
    registerEvent("onPaint",function()updateEvent()end)
end
Fawn.Runtime={InputEvent=updateOK and"onUpdate"or"onPaint fallback",PaintEvent=paintOK and"onPaint"or"paint",Font="Verdana",Reference="Fawn Modern reference geometry + Fawn behavioral contract",Renderer="unified shell + modal pointer routing + managed storage + preset settings",NoFakeShadows=true,SolidOutline=true,CorrectDrawImageSignature="textureId,x,y,w,h,Color3,alpha",ContainerScrolling="reserved section/page gutters + nested ownership + hover/drag accent feedback",Resize="deferred mouse-anchored UI scale + frozen screen-space physical resize",ESPWidgets="original Fawn cursor-follow drag parity + 8-slot commit + stacking reorder, reset and shuffle tools",ColorPicker="original Fawn HSV/SV + hue + alpha picker with color clipboard",Input="original Fawn caret-aware single-line text input with horizontal text window",DropdownScroll="fractional visual interpolation + numeric drag geometry + dedicated gutter",AccessoryPopup="extensible embedded-keybind three-dot popup",KeybindMode="original Fawn: left-click armed capture; Backspace clears; right-click Hold/Toggle/Always On; settings toggle key works while preserving edit isolation",Outline="single solid outer outline + inset rounded strokes",ContainerSeparation="stable gutters + no implicit column splits + responsive wrap geometry"}


-- 9.8 integrated finishing layer ---------------------------------------------------
do local function __fawn_apply_981(Fawn)
    if Fawn.__Polish98 then return end

local Window=assert(Fawn.Classes and Fawn.Classes.Window,"Fawn Window class missing")
local Overlay=Fawn.Classes and Fawn.Classes.Overlay
local REF=Fawn.Reference or(Fawn.Layout and Fawn.Layout.Reference)or{}
REF.Full=REF.Full or(Fawn.Layout and Fawn.Layout.Full)or{}
local floor,exp,max,min,abs=math.floor,math.exp,math.max,math.min,math.abs
local function clamp(v,a,b)if v<a then return a elseif v>b then return b end return v end
local function round(v)return floor(v+.5)end
local function copy(t)local q={}for k,v in pairs(type(t)=="table"and t or{})do q[k]=type(v)=="table"and copy(v)or v end return q end
local function idx(t,v)for i,x in ipairs(t or{})do if x==v then return i end end return 1 end
local function rgba(v,d)d=d or{255,255,255,255};if type(v)~="table"then return copy(d)end;return{clamp(round(v[1]or v.r or d[1]),0,255),clamp(round(v[2]or v.g or d[2]),0,255),clamp(round(v[3]or v.b or d[3]),0,255),clamp(round(v[4]or v.a or d[4]or 255),0,255)}end
local function blend(a,b,t)t=clamp(t,0,1);return{round((a[1]or 255)+((b[1]or 255)-(a[1]or 255))*t),round((a[2]or 255)+((b[2]or 255)-(a[2]or 255))*t),round((a[3]or 255)+((b[3]or 255)-(a[3]or 255))*t),round((a[4]or 255)+((b[4]or 255)-(a[4]or 255))*t)}end
local function rgb(c)return Color3.fromRGB(clamp(round(c[1]or 255),0,255),clamp(round(c[2]or 255),0,255),clamp(round(c[3]or 255),0,255))end
local function safe(name,...)local fn=draw and draw[name];if type(fn)~="function"then return false end;return pcall(fn,...)end
local function rect(x,y,w,h,c,r,a)if w<=0 or h<=0 then return end;safe("RectFilled",floor(x),floor(y),max(1,floor(w+.5)),max(1,floor(h+.5)),rgb(c),max(0,tonumber(r)or 0),clamp(round(a==nil and(c[4]or 255)or a),0,255))end
local function line(x1,y1,x2,y2,c,t,a)safe("Line",x1,y1,x2,y2,rgb(c),tonumber(t)or 1,clamp(round(a==nil and(c[4]or 255)or a),0,255))end
local function circle(x,y,r,c,a)safe("CircleFilled",x,y,max(0,r),rgb(c),32,clamp(round(a==nil and(c[4]or 255)or a),0,255))end
local function frameDt()local ok,v=pcall(function()return utility.GetDeltaTime()end);v=ok and tonumber(v)or 1/60;return clamp(v,1/240,1/20)end

local SURFACES={
    Solid={opacity=1.00,bias=0,mix={main=0,sidebar=0,card=1,control=1,popup=1,overlay=1},highlight=0},
    Frosted={opacity=.86,bias=0,mix={main=.08,sidebar=.34,card=.72,control=.90,popup=.94,overlay=.88},highlight=12},
    Acrylic={opacity=.80,bias=-8,mix={main=.12,sidebar=.38,card=.78,control=.94,popup=.97,overlay=.92},highlight=17},
    Smoke={opacity=.92,bias=9,mix={main=.05,sidebar=.27,card=.62,control=.84,popup=.90,overlay=.84},highlight=7},
    Clear={opacity=.68,bias=-28,mix={main=.16,sidebar=.42,card=.82,control=.96,popup=.98,overlay=.94},highlight=20}
}
local SURFACE_NAMES={"Solid","Frosted","Acrylic","Smoke","Clear"}
local MOTIONS={Off={speed=1000},Minimal={speed=24},Smooth={speed=13},Snappy={speed=22},Fluid={speed=9}}
local MOTION_NAMES={"Off","Minimal","Smooth","Snappy","Fluid"}
local CORNERS={Square=0,Tight=9,Soft=16,Round=22}
local CORNER_NAMES={"Square","Tight","Soft","Round"}
local DIVIDERS={"Connected","Inset"}

local function polishDefaults(w,opt)
    opt=type(opt)=="table"and opt or{}
    if w._polish98Init then return w end
    w._polish98Init=true
    w.surfaceStyle=opt.surfaceStyle or(w.liquidGlass and"Frosted"or"Solid")
    if not SURFACES[w.surfaceStyle]then w.surfaceStyle=w.liquidGlass and"Frosted"or"Solid"end
    w.radiusScale=clamp(tonumber(opt.radiusScale)or 1,.45,1.65)
    w.outlineOpacity=clamp(tonumber(opt.outlineOpacity)or 1,.15,1)
    w.surfaceHighlights=opt.surfaceHighlights~=false
    w.sidebarStitch=opt.sidebarStitch~=false
    w.profileDivider=opt.profileDivider or"Connected"
    w.hoverAnimations=opt.hoverAnimations~=false
    w.switchAnimations=opt.switchAnimations~=false
    w.motionStyle=opt.motionStyle or"Smooth"
    if not MOTIONS[w.motionStyle]then w.motionStyle="Smooth"end
    w.surfaceAlphaOverrides=type(opt.surfaceAlphaOverrides)=="table"and copy(opt.surfaceAlphaOverrides)or{}
    w.surfaceTintOverrides=type(opt.surfaceTintOverrides)=="table"and copy(opt.surfaceTintOverrides)or{}
    w.glassTint=rgba(opt.glassTint or w:_color("accent"))
    w.glassTintStrength=clamp(tonumber(opt.glassTintStrength)or .035,0,.65)
    w._polishFillAnim={}
    w._polishSwitchAnim={}
    return w
end

local function motionSpeed(w)
    local p=MOTIONS[w.motionStyle]or MOTIONS.Smooth
    local base=tonumber(w.animationSpeed)or 10
    return max(.1,p.speed*(base/10))
end
local function animScalar(w,bucket,key,target,speed)
    if not w.animations or w.motionStyle=="Off"then bucket[key]=target return target end
    local cur=bucket[key]
    if cur==nil then cur=target end
    local a=1-exp(-max(.1,speed or motionSpeed(w))*frameDt())
    cur=cur+(target-cur)*a
    if abs(cur-target)<.001 then cur=target end
    bucket[key]=cur
    return cur
end
local function animColor(w,key,target)
    if not w.animations or w.motionStyle=="Off"or w.hoverAnimations==false then return target end
    local b=w._polishFillAnim or{};w._polishFillAnim=b
    local q=b[key]
    if type(q)~="table"then q={target[1],target[2],target[3],target[4]or 255};b[key]=q end
    local a=1-exp(-motionSpeed(w)*frameDt())
    for i=1,4 do local t=target[i]or 255;q[i]=q[i]+(t-q[i])*a;if abs(q[i]-t)<.5 then q[i]=t end end
    return{round(q[1]),round(q[2]),round(q[3]),round(q[4])}
end
local function surfacePreset(w)return SURFACES[w.surfaceStyle]or SURFACES.Frosted end
local function surfaceColor(w,role,c)
    c=rgba(c)
    if not w.liquidGlass or w.surfaceStyle=="Solid"then return c end
    local p=surfacePreset(w);local root=rgba(w:_color("menuBg"));local mix=p.mix[role]or 1
    local target=c
    if role=="sidebar" then target=blend(c,rgba(w:_color("card")),.34) end
    local out=blend(root,target,mix)
    if type(w.glassTint)=="table" and (w.glassTintStrength or 0)>0 then out=blend(out,rgba(w.glassTint),clamp(w.glassTintStrength,0,.65)) end
    local tint=w.surfaceTintOverrides and w.surfaceTintOverrides[role]
    if type(tint)=="table"then out=blend(out,rgba(tint.color or tint),clamp(tonumber(tint.strength)or .12,0,1))end
    return out
end
local function surfaceAlpha(w,role,base,explicit)
    if explicit~=nil then return clamp(tonumber(explicit)or 255,0,255)end
    if not w.liquidGlass or w.surfaceStyle=="Solid"then return clamp(tonumber(base)or 255,0,255)end
    local over=w.surfaceAlphaOverrides and w.surfaceAlphaOverrides[role]
    if over~=nil then local n=tonumber(over)or 255;if n<=1 then n=n*255 end;return clamp(n,0,255)end
    local p=surfacePreset(w);local op=clamp(tonumber(w.glassOpacity)or p.opacity,.18,1)
    local root=90+op*155+p.bias
    local add={main=0,sidebar=0,card=11,control=24,popup=30,overlay=22}
    return clamp(root+(add[role]or 0),64,246)
end

local oldCreateWindow=Fawn.CreateWindow
function Fawn:CreateWindow(opt)local w=oldCreateWindow(self,opt);return polishDefaults(w,opt)end
for _,w in ipairs(Fawn.GetWindows and Fawn:GetWindows()or{})do polishDefaults(w,{})end

local oldSetLiquidGlass=Window.SetLiquidGlass
function Window:SetLiquidGlass(v)
    polishDefaults(self,{})
    oldSetLiquidGlass(self,v)
    if v and(self.surfaceStyle==nil or self.surfaceStyle=="Solid")then self.surfaceStyle="Frosted" end
    return self
end
function Window:SetSurfaceStyle(name,preserveOpacity)
    polishDefaults(self,{})
    name=tostring(name or"Frosted");if not SURFACES[name]then return self end
    self.surfaceStyle=name
    if name=="Solid"then oldSetLiquidGlass(self,false)else oldSetLiquidGlass(self,true);if preserveOpacity==false then self.glassOpacity=SURFACES[name].opacity end end
    self._polishFillAnim={}
    return self
end
function Window:GetSurfaceStyle()polishDefaults(self,{})return self.surfaceStyle end
function Window:SetSurfaceOpacity(role,value)polishDefaults(self,{});role=tostring(role or"main");local n=tonumber(value);if n then self.surfaceAlphaOverrides[role]=n end;return self end
function Window:ClearSurfaceOpacity(role)polishDefaults(self,{});self.surfaceAlphaOverrides[tostring(role or"main")]=nil;return self end
function Window:SetSurfaceTint(role,color,strength)polishDefaults(self,{});self.surfaceTintOverrides[tostring(role or"main")]={color=rgba(color),strength=clamp(tonumber(strength)or .12,0,1)};return self end
function Window:ClearSurfaceTint(role)polishDefaults(self,{});self.surfaceTintOverrides[tostring(role or"main")]=nil;return self end
function Window:SetGlassTint(color,strength)polishDefaults(self,{});self.glassTint=rgba(color,self.glassTint);if strength~=nil then self.glassTintStrength=clamp(tonumber(strength)or self.glassTintStrength,0,.65)end;self._polishFillAnim={};return self end
function Window:GetGlassTint()polishDefaults(self,{});return copy(self.glassTint),self.glassTintStrength end
function Window:SetGlassTintStrength(v)polishDefaults(self,{});local n=tonumber(v)or self.glassTintStrength;if n>1 then n=n/100 end;self.glassTintStrength=clamp(n,0,.65);self._polishFillAnim={};return self end
function Window:ClearGlassTint()polishDefaults(self,{});self.glassTint=rgba(self:_color("accent"));self.glassTintStrength=0;self._polishFillAnim={};return self end
function Window:SetSurfaceHighlights(v)polishDefaults(self,{});self.surfaceHighlights=v~=false;return self end
function Window:SetSidebarStitch(v)polishDefaults(self,{});self.sidebarStitch=v~=false;return self end
function Window:SetProfileDivider(v)polishDefaults(self,{});v=tostring(v or"Connected");self.profileDivider=(v=="Inset")and"Inset"or"Connected";return self end
function Window:SetRadiusScale(v)polishDefaults(self,{});self.radiusScale=clamp(tonumber(v)or 1,.45,1.65);return self end
function Window:SetCornerPreset(name)name=tostring(name or"Round");if CORNERS[name]~=nil then self:SetCornerRadius(CORNERS[name])end;return self end
function Window:SetOutlineOpacity(v)polishDefaults(self,{});local n=tonumber(v)or 1;if n>1 then n=n/100 end;self.outlineOpacity=clamp(n,.15,1);return self end
function Window:SetMotionStyle(name)polishDefaults(self,{});name=tostring(name or"Smooth");if not MOTIONS[name]then return self end;self.motionStyle=name;self.animations=name~="Off";return self end
function Window:GetMotionStyle()polishDefaults(self,{})return self.motionStyle end
function Window:SetHoverAnimations(v)polishDefaults(self,{});self.hoverAnimations=v~=false;if not self.hoverAnimations then self._polishFillAnim={}end;return self end
function Window:SetSwitchAnimations(v)polishDefaults(self,{});self.switchAnimations=v~=false;if not self.switchAnimations then self._polishSwitchAnim={}end;return self end
function Window:ResetPolish()
    self.surfaceStyle=self.liquidGlass and"Frosted"or"Solid"
    self.glassTint=rgba(self:_color("accent"));self.glassTintStrength=.035
    self.radiusScale=1;self.outlineOpacity=1;self.surfaceHighlights=true;self.sidebarStitch=true;self.profileDivider="Connected";self.hoverAnimations=true;self.switchAnimations=true;self.motionStyle="Smooth";self.surfaceAlphaOverrides={};self.surfaceTintOverrides={};self._polishFillAnim={};self._polishSwitchAnim={}
    return self
end

local oldFill=Window._fill
function Window:_fill(role,x,y,w,h,key,r,a)
    polishDefaults(self,{})
    if self.surfaceStyle=="Solid"and(not self.animations or self.hoverAnimations==false)and self.radiusScale==1 then return oldFill(self,role,x,y,w,h,key,r,a)end
    local c=surfaceColor(self,role,self:_color(key));local aa=surfaceAlpha(self,role,c[4]or 255,a);c[4]=aa
    local id=role..":"..floor(x+.5)..":"..floor(y+.5)..":"..floor(w+.5)..":"..floor(h+.5)
    c=animColor(self,id,c)
    local rr=max(0,(tonumber(r)or 0)*(self.radiusScale or 1))
    rect(x,y,w,h,c,rr,c[4])
    if self.liquidGlass and self.surfaceHighlights and w>28 and h>12 then
        local p=surfacePreset(self);local ha=min(9,p.highlight or 0)
        if ha>0 and(role=="card"or role=="popup"or role=="overlay")then
            local ss=self.scale or 1;local inset=min(max(7*ss,rr*.65),w*.20)
            line(x+inset,y+2*ss,x+w-inset,y+2*ss,self:_color("white"),max(.75,ss*.65),ha)
        end
    end
end
local oldOut=Window._out
function Window:_out(x,y,w,h,r,t,c,a)
    polishDefaults(self,{})
    local rr=max(0,(tonumber(r)or 0)*(self.radiusScale or 1))
    local oc=rgba(c or self.outlineColor or self:_color("outline"))
    if self.liquidGlass then
        local bg=surfaceColor(self,"main",self:_color("menuBg"))
        oc=blend(bg,oc,.72)
    end
    local aa=a~=nil and clamp(tonumber(a)or 255,0,255)or(self.liquidGlass and 168 or 255)
    aa=clamp(aa*(self.outlineOpacity or 1),0,255)
    local th=max(.75,(tonumber(t)or self.borderThickness or 1)*(self.outlineStrength or 1))
    safe("Rect",floor(x),floor(y),max(1,floor(w+.5)),max(1,floor(h+.5)),rgb(oc),th,rr,aa)
end

function Window:_drawToggle(x,cy,on,disabled)
    polishDefaults(self,{})
    local s=self.scale;local F=REF.Full;local w=(F.togW or 55)*s;local h=(F.togH or 28)*s;local knob=(F.knob or 24)*s;local xx=x-w
    local key=self._activeControlAnimId or(floor(xx+.5)..":"..floor(cy+.5)..":"..floor(w+.5));local target=on and 1 or 0;local p=target
    if self.animations and self.switchAnimations and self.motionStyle~="Off"then p=animScalar(self,self._polishSwitchAnim,key,target,motionSpeed(self)*1.15)else self._polishSwitchAnim[key]=target end
    local off=rgba(self:_color("toggleTrack"));local oncol=rgba(self:_color("accent"));local col=blend(off,oncol,p)
    if disabled then col=blend(col,rgba(self:_color("menuBg")),.45)end
    rect(xx,cy-h*.5,w,h,col,h*.5,surfaceAlpha(self,"control",255,nil))
    local pad=(h-knob)*.5;local k0=xx+pad+knob*.5;local k1=xx+w-pad-knob*.5;local kx=k0+(k1-k0)*p
    circle(kx,cy,knob*.5,blend(rgba(self:_color("toggleKnob")),rgba(self:_color("white")),p),255)
    return xx,cy-h*.5,w,h
end

function Window:_drawLogo()
    local s=self.scale;local X,Y=self.x,self.y
    local lx,ly=X+25*s,Y+20*s
    self:_fill("control",lx,ly,50*s,50*s,"logoBg",12*s,255)
    if self.logoImage then drawImage(self.logoImage,lx+5*s,ly+5*s,40*s,40*s,1)else
        local lw,lh=measure(self.logo,24*s,"Verdana");text(self.logo,lx+25*s-lw*.5,ly+25*s-lh*.5,self:_color("logoFg"),24*s,"Verdana")
    end
    local tx=X+98*s;local maxW=max(38*s,(REF.Sidebar-118)*s)
    textC(fit(self.brand,maxW,22*s,"Verdana"),tx,Y+33*s,self:_color("white"),22*s,"Verdana")
    local lines=wrapText(self.subtitle,maxW,11*s,"Verdana",2)
    if #lines==0 then lines={""}end
    local baseY=Y+50*s;local step=12*s
    for i,v in ipairs(lines)do textC(v,tx,baseY+(i-1)*step,self:_color("muted"),11*s,"Verdana")end
end

function Window:_drawSidebar()
    polishDefaults(self,{})
    if self.kind=="Panel"or self.tabBarVisible==false then return end
    local s=self.scale;local X,Y=self.x,self.y;local sidebarW=REF.Sidebar*s;local H=self.height*s
    -- The outer Window is the only shell surface. Do not repaint the sidebar on top of
    -- translucent main glass; that caused doubled opacity, dirty corners and the broken footer.
    if self.surfaceAlphaOverrides and self.surfaceAlphaOverrides.sidebar~=nil then
        local c=surfaceColor(self,"sidebar",self:_color("menuBg"));local aa=surfaceAlpha(self,"sidebar",c[4]or 255,nil)
        rect(X+1*s,Y+1*s,sidebarW-2*s,H-2*s,c,0,min(55,aa))
    end
    self:_drawLogo()
    local divider=blend(surfaceColor(self,"main",self:_color("menuBg")),rgba(self:_color("outline")),self.liquidGlass and .62 or .76)
    local divA=self.liquidGlass and 118 or 92
    if self.sidebarStitch~=false then line(X+sidebarW,Y+1*s,X+sidebarW,Y+H-1*s,divider,max(.8,s),divA*(self.outlineOpacity or 1))end
    line(X+15*s,Y+91*s,X+sidebarW-12*s,Y+91*s,divider,max(.8,s),62*(self.outlineOpacity or 1))

    local groups,order={},{}
    for _,t in ipairs(self:_visibleTabs())do local g=t.group or"MAIN";if not groups[g]then groups[g]={};order[#order+1]=g end;groups[g][#groups[g]+1]=t end
    local navTop,profileY=self:_sidebarGeometry();local available=max(80*s,profileY-navTop-18*s);local contentH=0
    for _,g in ipairs(order)do contentH=contentH+26*s+#groups[g]*60*s+29*s end
    local maxScroll=max(0,contentH-available);self.sidebarTarget=clamp(self.sidebarTarget or 0,0,maxScroll)
    if self:_hit(X,navTop,sidebarW,available)and Input.wheel~=0 and not self:_hasPopup()then self.sidebarTarget=clamp(self.sidebarTarget+Input.wheel*60*s,0,maxScroll)end
    if self._sidebarDrag then
        if Input.left and maxScroll>0 then local rr=snapRatio96((Input.my-self._sidebarDrag.top-self._sidebarDrag.off)/max(1,self._sidebarDrag.span));self.sidebarTarget=rr*maxScroll;self.sidebarScroll=self.sidebarTarget else self._sidebarDrag=nil end
    end
    self.sidebarScroll,self.sidebarTarget=settle96(self.sidebarScroll,self.sidebarTarget,maxScroll,self.scrollSpeed,s,self._sidebarDrag~=nil or self.smoothScroll==false)
    local y=navTop-(self.sidebarScroll or 0)
    for _,g in ipairs(order)do
        if y>=navTop and y+20*s<=navTop+available then textC(upper(g),X+33*s,y+7*s,self:_color("muted"),14*s,"Verdana")end
        y=y+26*s
        for _,tab in ipairs(groups[g])do
            local ix,iy,iw,ih=X+17*s,y,241*s,55*s;local visible=iy>=navTop and iy+ih<=navTop+available
            if visible then
                local active=tab==self.activeTab;local hov=self:_hit(ix,iy,iw,ih)and not self:_hasPopup()
                if active then self:_fill("control",ix,iy,iw,ih,"activeItem",12*s)elseif hov then rect(ix,iy,iw,ih,self:_color("white"),12*s,10)end
                self:_icon(iconForTab(tab),X+43*s,iy+27.5*s,22*s,active and"accent"or"icon")
                textC(fit(tab.name,168*s,20*s,"Verdana"),X+72*s,iy+27.5*s,self:_color(active and"white"or"navText"),20*s,"Verdana")
                if Input.click and not self._consumed and not self:_hasPopup()and hov then self:SelectTab(tab);self:_consume()end
            end
            y=y+60*s
        end
        y=y+29*s
    end
    if maxScroll>0 then
        local tx=X+263*s;local th=available;local thumb=max(32*s,th*(available/contentH));local span=max(1,th-thumb);local ty=navTop+span*((self.sidebarScroll or 0)/maxScroll)
        local trackHover=self:_hit(tx-7*s,navTop,15*s,th);local thumbHover=self:_hit(tx-7*s,ty-3*s,15*s,thumb+6*s);local active=self._sidebarDrag~=nil
        if trackHover or active then rect(tx-1*s,navTop,2*s,th,self:_color("controlHover"),1*s,92)end
        rect(tx-((active or thumbHover)and 1.5*s or 1*s),ty,(active or thumbHover)and 5*s or 4*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 245 or 175)
        if Input.click and not self._consumed and not self:_hasPopup()and thumbHover then self._sidebarDrag={top=navTop,span=span,off=Input.my-ty};self:_consume()end
    else self._sidebarDrag=nil end

    -- Footer/profile is drawn directly on the single shell. No opaque cleanup rectangle.
    local fy=profileY-15*s
    if self.profileDivider=="Inset"then line(X+15*s,fy,X+sidebarW-15*s,fy,divider,max(.8,s),72*(self.outlineOpacity or 1))
    else line(X+15*s,fy,X+sidebarW-1*s,fy,divider,max(.8,s),72*(self.outlineOpacity or 1))end
    local ux,uy,uw,uh=X+15*s,profileY,245*s,55*s
    local phov=self:_hit(ux,uy,uw,uh)and not(self.openDrop or self.keyMenu or self.colorPopup or self.configPopup or self.groupPopup)
    if phov or self.accountOpen then self:_fill("control",ux,uy,uw,uh,"activeItem",12*s)end
    if self.profileImage then drawImage(self.profileImage,ux+8*s,uy+8*s,39*s,39*s,1)
    else circle(ux+27.5*s,uy+27.5*s,19.5*s,self:_color("avatar"),255);circle(ux+27.5*s,uy+22*s,6.5*s,self:_color("avatarDark"),255);safe("Rect",floor(ux+17*s),floor(uy+31*s),max(1,floor(21*s+.5)),max(1,floor(11*s+.5)),rgb(self:_color("avatarDark")),2*s,6*s,255)end
    textC(fit(self.profileName,139*s,16*s,"Verdana"),ux+58*s,uy+21*s,self:_color("text"),16*s,"Verdana")
    textC(fit(self.profileSubtitle,139*s,12*s,"Verdana"),ux+58*s,uy+39*s,self:_color("muted"),12*s,"Verdana")
    local target=self.accountOpen and 90 or 0;if self.animations then self.accountAnim=self.accountAnim+(target-self.accountAnim)*min(1,dt()*self.animationSpeed)else self.accountAnim=target end
    chev(self,ux+222*s,uy+27.5*s,16*s,self:_color("muted"),self.accountAnim)
    if Input.click and not self._consumed and phov and not(self.openDrop or self.keyMenu or self.colorPopup or self.configPopup or self.groupPopup)then if type(self.profileClick)=="function"then pcall(self.profileClick,self)else self.accountOpen=not self.accountOpen end;self:_consume()end
end

if Overlay and type(Overlay._frame)=="function"then
    local oldOverlayFrame=Overlay._frame
    function Overlay:_frame(x,y,w,h,header)
        local win=self.window
        if not win or not win._polish98Init then return oldOverlayFrame(self,x,y,w,h,header)end
        local s=win.scale or 1;local c=surfaceColor(win,"overlay",self:_theme("popup"));local a=surfaceAlpha(win,"overlay",c[4]or 255,nil);rect(x,y,w,h,c,10*s*(win.radiusScale or 1),a)
        win:_out(x,y,w,h,10*s,max(.8,s),win.outlineColor or self:_theme("outline"),170)
        if header then local hc=blend(surfaceColor(win,"main",win:_color("menuBg")),rgba(self:_theme("outline")),.62);line(x+1*s,y+header,x+w-1*s,y+header,hc,max(.75,s*.7),48*(win.outlineOpacity or 1))end
    end
end

local oldGetStyle=Window.GetStyle
function Window:GetStyle()local q=oldGetStyle(self);polishDefaults(self,{});q.surfaceStyle=self.surfaceStyle;q.glassTint=copy(self.glassTint);q.glassTintStrength=self.glassTintStrength;q.radiusScale=self.radiusScale;q.outlineOpacity=self.outlineOpacity;q.surfaceHighlights=self.surfaceHighlights;q.sidebarStitch=self.sidebarStitch;q.profileDivider=self.profileDivider;q.motionStyle=self.motionStyle;q.hoverAnimations=self.hoverAnimations;q.switchAnimations=self.switchAnimations;return q end
local oldSetStyle=Window.SetStyle
function Window:SetStyle(t)oldSetStyle(self,t);if type(t)=="table"then if t.surfaceStyle then self:SetSurfaceStyle(t.surfaceStyle,t.preserveGlassOpacity)end;if t.glassTint then self:SetGlassTint(t.glassTint,t.glassTintStrength)elseif t.glassTintStrength~=nil then self:SetGlassTintStrength(t.glassTintStrength)end;if t.radiusScale then self:SetRadiusScale(t.radiusScale)end;if t.outlineOpacity then self:SetOutlineOpacity(t.outlineOpacity)end;if t.surfaceHighlights~=nil then self:SetSurfaceHighlights(t.surfaceHighlights)end;if t.sidebarStitch~=nil then self:SetSidebarStitch(t.sidebarStitch)end;if t.profileDivider then self:SetProfileDivider(t.profileDivider)end;if t.motionStyle then self:SetMotionStyle(t.motionStyle)end;if t.hoverAnimations~=nil then self:SetHoverAnimations(t.hoverAnimations)end;if t.switchAnimations~=nil then self:SetSwitchAnimations(t.switchAnimations)end end;return self end

local oldGetConfig=Window.GetConfig
function Window:GetConfig()
    local q=oldGetConfig(self);polishDefaults(self,{})
    q.polish={surfaceStyle=self.surfaceStyle,glassTint=copy(self.glassTint),glassTintStrength=self.glassTintStrength,radiusScale=self.radiusScale,outlineOpacity=self.outlineOpacity,surfaceHighlights=self.surfaceHighlights,sidebarStitch=self.sidebarStitch,profileDivider=self.profileDivider,motionStyle=self.motionStyle,hoverAnimations=self.hoverAnimations,switchAnimations=self.switchAnimations,surfaceAlphaOverrides=copy(self.surfaceAlphaOverrides),surfaceTintOverrides=copy(self.surfaceTintOverrides)}
    return q
end
local oldLoadConfig=Window.LoadConfig
function Window:LoadConfig(cfg,silent)
    oldLoadConfig(self,cfg,silent);polishDefaults(self,{})
    local glassAfter=nil;if type(cfg)=="table"and type(cfg.style)=="table"and cfg.style.liquidGlass~=nil then glassAfter=cfg.style.liquidGlass end
    local p=type(cfg)=="table"and cfg.polish or nil
    if type(p)=="table"then
        if p.surfaceStyle and SURFACES[p.surfaceStyle]then self:SetSurfaceStyle(p.surfaceStyle,true)end
        if p.glassTint then self:SetGlassTint(p.glassTint,p.glassTintStrength)elseif p.glassTintStrength~=nil then self:SetGlassTintStrength(p.glassTintStrength)end
        if p.radiusScale then self:SetRadiusScale(p.radiusScale)end;if p.outlineOpacity then self:SetOutlineOpacity(p.outlineOpacity)end
        if p.surfaceHighlights~=nil then self:SetSurfaceHighlights(p.surfaceHighlights)end;if p.sidebarStitch~=nil then self:SetSidebarStitch(p.sidebarStitch)end
        if p.profileDivider then self:SetProfileDivider(p.profileDivider)end;if p.motionStyle then self:SetMotionStyle(p.motionStyle)end
        if p.hoverAnimations~=nil then self:SetHoverAnimations(p.hoverAnimations)end;if p.switchAnimations~=nil then self:SetSwitchAnimations(p.switchAnimations)end
        if type(p.surfaceAlphaOverrides)=="table"then self.surfaceAlphaOverrides=copy(p.surfaceAlphaOverrides)end;if type(p.surfaceTintOverrides)=="table"then self.surfaceTintOverrides=copy(p.surfaceTintOverrides)end
    end
    if glassAfter~=nil then oldSetLiquidGlass(self,glassAfter)end
    return self
end

local oldSettings=Fawn.CreateSettingsPage
function Fawn:CreateSettingsPage(window,opt)
    local page=oldSettings(self,window,opt)
    if page and not page._polish98Extended then
        page._polish98Extended=true;local w=page.Window;polishDefaults(w,{})
        local surfaces=page.Tab:Section("SURFACES",{column=1,row=4,sizeMode="auto"})
        local motion=page.Tab:Section("MOTION",{column=2,row=4,sizeMode="auto"})
        page.Controls.SurfaceStyle=surfaces:Dropdown("Surface Material",SURFACE_NAMES,idx(SURFACE_NAMES,w.surfaceStyle),{noConfig=true})
        page.Controls.SurfaceStyle:OnChanged(function(v)w:SetSurfaceStyle(v);if page.Controls.Glass then page.Controls.Glass:Set(w:GetLiquidGlass(),true)end end)
        page.Controls.GlassTint=surfaces:ColorPicker("Glass Tint",w.glassTint,{noConfig=true});page.Controls.GlassTint:OnChanged(function(v)w:SetGlassTint(v)end)
        page.Controls.GlassTintStrength=surfaces:Slider("Tint Strength",0,65,round((w.glassTintStrength or 0)*100),{noConfig=true,format=function(v)return round(v).."%"end});page.Controls.GlassTintStrength:OnChanged(function(v)w:SetGlassTintStrength(v/100)end)
        if page.Controls.Glass then local glassCallback=page.Controls.Glass.callback;page.Controls.Glass:OnChanged(function(v)if glassCallback then glassCallback(v)else w:SetLiquidGlass(v)end;page.Controls.SurfaceStyle:Set(w:GetSurfaceStyle(),true)end)end
        page.Controls.CornerPreset=surfaces:Dropdown("Corner Preset",CORNER_NAMES,idx(CORNER_NAMES,"Round"),{noConfig=true})
        page.Controls.CornerPreset:OnChanged(function(v)w:SetCornerPreset(v)end)
        page.Controls.RadiusScale=surfaces:Slider("Radius Scale",45,165,round((w.radiusScale or 1)*100),{noConfig=true,format=function(v)return round(v).."%"end})
        page.Controls.RadiusScale:OnChanged(function(v)w:SetRadiusScale(v/100)end)
        page.Controls.OutlineOpacity=surfaces:Slider("Outline Opacity",15,100,round((w.outlineOpacity or 1)*100),{noConfig=true,format=function(v)return round(v).."%"end})
        page.Controls.OutlineOpacity:OnChanged(function(v)w:SetOutlineOpacity(v/100)end)
        page.Controls.SurfaceHighlights=surfaces:Toggle("Glass Highlights",w.surfaceHighlights,{noConfig=true});page.Controls.SurfaceHighlights:OnChanged(function(v)w:SetSurfaceHighlights(v)end)
        page.Controls.ProfileDivider=surfaces:Dropdown("Profile Divider",DIVIDERS,idx(DIVIDERS,w.profileDivider),{noConfig=true});page.Controls.ProfileDivider:OnChanged(function(v)w:SetProfileDivider(v)end)
        page.Controls.MotionStyle=motion:Dropdown("Animation Style",MOTION_NAMES,idx(MOTION_NAMES,w.motionStyle),{noConfig=true});page.Controls.MotionStyle:OnChanged(function(v)w:SetMotionStyle(v)end)
        page.Controls.MotionSpeed=motion:Slider("Animation Speed",4,30,round(w.animationSpeed or 10),{noConfig=true});page.Controls.MotionSpeed:OnChanged(function(v)w:SetAnimationSpeed(v)end)
        page.Controls.HoverAnimations=motion:Toggle("Animated Hovers",w.hoverAnimations,{noConfig=true});page.Controls.HoverAnimations:OnChanged(function(v)w:SetHoverAnimations(v)end)
        page.Controls.SwitchAnimations=motion:Toggle("Animated Switches",w.switchAnimations,{noConfig=true});page.Controls.SwitchAnimations:OnChanged(function(v)w:SetSwitchAnimations(v)end)
        motion:AddButtonPair("Reset Motion",function()w:SetMotionStyle("Smooth"):SetAnimationSpeed(10):SetHoverAnimations(true):SetSwitchAnimations(true)end,"Reset Polish",function()w:ResetPolish()end)
    end
    return page
end

-- Final shell pass: one rounded root, no stacked bottom/top masks.
-- Content is already clipped in the layout/Section pass, so repainting thin full-width
-- chrome masks only damages the outer radii and creates the disconnected-corner look.
function Window:_render()
    if self.destroyed then return end
    if self._pendingScale then local q=self._pendingScale;self._pendingScale=nil;self._inRender=false;self:SetScale(q)end
    self:_toggleByKey();self:_processKeybinds();self:_processBindCapture();self:_processInputEdit();self:_processSliderEdit()
    if not self.visible then return end
    self._inRender=true;self._consumed=false;self:_updateWindowDragResize()
    local s=self.scale;local X,Y=self.x,self.y;local W,H=self.width*s,self.height*s
    local I=Fawn.GetInputState and Fawn:GetInputState()or{}
    if (I.click or I.rightClick)and not self._consumed and self:_hasPopup()then
        local inside=false
        for _,p in pairs({self.openDrop,self.extraPopup,self.keyMenu,self.colorPopup,self.colorMenu,self.configPopup,self.groupPopup})do
            if p and p.x and p.y and p.w and p.h and self:_hit(p.x,p.y,p.w,p.h)then inside=true break end
        end
        if self.accountOpen then local _,py=self:_sidebarGeometry();if self:_hit(X+7*s,py-244*s,261*s,236*s)or self:_hit(X+15*s,py,245*s,55*s)then inside=true end end
        if self.searchOpen then local sw=310*s;local sx=X+(self.width-(REF.RightMargin or 32))*s-sw;local sy=Y+78*s;if self:_hit(sx,sy,sw,44*s)then inside=true end end
        if not inside then self:_closePopups();self:_consume()end
    end
    self:_fill("main",X,Y,W,H,"menuBg",(self.corner or 22)*s)
    self:_drawContent()
    if self.kind=="Panel"or self.tabBarVisible==false then self:_drawPanelHeader()else self:_drawSidebar();self:_drawTopbar()end
    self:_out(X,Y,W,H,(self.corner or 22)*s,self.borderThickness,self.outlineColor,255)
    if self._drawExtraPopup then self:_drawExtraPopup()end
    self:_drawDropdownPopup();self:_drawKeyMenu();self:_drawColorPopup();if self._drawColorMenu then self:_drawColorMenu()end;self:_drawConfigPopup();self:_drawGroupPopup();self:_drawAccountPopup();self:_drawSearchPopup()
    self._inRender=false
end

Fawn.SurfaceStyles=copy(SURFACE_NAMES)
Fawn.MotionStyles=copy(MOTION_NAMES)
Fawn.CornerPresets=copy(CORNER_NAMES)
Fawn.Style=Fawn.Style or{}
Fawn.Style.PolishLayer=true
Fawn.Style.SingleShell=true
Fawn.Style.ConnectedProfileDivider=true
Fawn.Style.SurfaceMaterials=copy(SURFACE_NAMES)
Fawn.Style.MotionStyles=copy(MOTION_NAMES)
-- numeric build identity intentionally omitted
-- numeric build identity intentionally omitted
-- numeric build identity intentionally omitted
-- numeric build identity intentionally omitted
-- numeric build identity intentionally omitted
Fawn.DynamicCapabilities=Fawn.DynamicCapabilities or{}
Fawn.DynamicCapabilities.SurfaceMaterials=true
Fawn.DynamicCapabilities.MotionStyles=true
Fawn.DynamicCapabilities.GlassTint=true
Fawn.DynamicCapabilities.SingleShell=true
Fawn.DynamicCapabilities.PixelPolishedSidebar=true
Fawn.DynamicCapabilities.WrappedBrandSubtitle=true
Fawn.Runtime=Fawn.Runtime or{}
Fawn.Runtime.PixelPolish98="single shell sidebar + glass-safe profile footer + wrapped brand subtitle + single-pass outlines"
Fawn.__Polish98=true
end
__fawn_apply_981(Fawn)
end

-- Fawn Modern customization, storage and secondary-UI cleanup pass.
do local function __fawn_apply_982(Fawn)
local Window=Fawn.Classes.Window
local Overlay=Fawn.Classes.Overlay
local ESPPreview=Fawn.Classes.ESPPreview
local Notification=Fawn.Classes.Notification
local ROOT="Fawn Modern"
local RELROOT=ROOT
local PATHS={Root=ROOT,Configs=ROOT.."/configs",ProfilePictures=ROOT.."/Profile Pictures",LogoPictures=ROOT.."/logo pictures"}
local REL={Configs=PATHS.Configs,ProfilePictures=PATHS.ProfilePictures,LogoPictures=PATHS.LogoPictures}
local SECONDARY={Padding=12,Radius=10,RowGap=6,HeaderInset=12,AccentInset=9}
local function cpy982(v,seen)
    if type(v)~="table"then return v end
    seen=seen or{};if seen[v]then return seen[v]end
    local q={};seen[v]=q;for k,x in pairs(v)do q[cpy982(k,seen)]=cpy982(x,seen)end;return q
end
local function clamp982(v,a,b)v=tonumber(v)or a;if v<a then return a elseif v>b then return b end return v end
local function round982(v)return math.floor((tonumber(v)or 0)+.5)end
local function fs982()return type(file)=="table"and file or nil end
local function callfs982(names,...)
    local f=fs982();if not f then return false,nil end
    for _,n in ipairs(names)do if type(f[n])=="function"then local ok,a,b,c=pcall(f[n],...);if ok then return true,a,b,c end end end
    return false,nil
end
local function mkdir982(path)
    local ok=callfs982({"mkdir","MakeDirectory","makeDirectory","CreateDirectory","createDirectory"},path)
    return ok
end
local function ensure982()
    mkdir982(ROOT);mkdir982(PATHS.Configs);mkdir982(PATHS.ProfilePictures);mkdir982(PATHS.LogoPictures)
    return PATHS
end
local function basename982(p)
    p=tostring(p or""):gsub("\\","/"):gsub("/+$","")
    return p:match("([^/]+)$")or p
end
local function ext982(p)return lower((tostring(p or""):match("%.([^%.%/\\]+)$")or""))end
local function normalizeList982(raw)
    local out,seen={},{ }
    if type(raw)=="string"then for s in raw:gmatch("[^\r\n]+")do local n=basename982(s);if n~=""and not seen[n]then seen[n]=true;out[#out+1]=n end end
    elseif type(raw)=="table"then
        for k,v in pairs(raw)do
            local s
            if type(v)=="string"then s=v elseif type(v)=="table"then s=v.path or v.Path or v.name or v.Name or v.file or v.File elseif type(k)=="string"and v==true then s=k end
            if s then local n=basename982(s);if n~=""and not seen[n]then seen[n]=true;out[#out+1]=n end end
        end
    end
    sort(out,function(a,b)return lower(a)<lower(b)end);return out
end
local function list982(path,kind)
    ensure982();local f=fs982();if not f then return{}end
    local raw=nil
    for _,n in ipairs({"list","List","listdir","ListDirectory","listFiles","ListFiles","listfiles","GetFiles","getFiles","getfiles","enumerate","Enumerate","ls"})do
        if type(f[n])=="function"then local ok,r=pcall(f[n],path);if ok and(type(r)=="table"or type(r)=="string")then raw=r;break end end
    end
    local out=normalizeList982(raw)
    if kind=="image"then local q={}for _,n in ipairs(out)do local e=ext982(n);if e=="png"or e=="jpg"or e=="jpeg"or e=="bmp"or e=="webp"then q[#q+1]=n end end;out=q
    elseif kind=="config"then local q={}for _,n in ipairs(out)do local e=ext982(n);if e=="lua"or e=="cfg"or e=="txt"or e=="json"then q[#q+1]=n end end;out=q end
    return out
end
local function resolve982(kind,name)
    name=tostring(name or""):gsub("\\","/")
    if name==""then return""end
    if name:match("^%a:[/\\]")or name:sub(1,1)=="/"then return name end
    local base=PATHS[kind]or ROOT
    if name:find("/",1,true)then
        if name:sub(1,#RELROOT)==RELROOT then return"C:/Serotonin/files/"..name end
        return name
    end
    return base.."/"..name
end
local function relConfig982(name)
    name=tostring(name or""):gsub("\\","/")
    if name==""then name="default.lua"end
    if not name:find("%.[^/]+$")then name=name..".lua"end
    if name:match("^%a:[/\\]")then return name end
    if name:find("/",1,true)then return name end
    return REL.Configs.."/"..name
end
local function fullConfig982(name)
    local r=relConfig982(name);if r:match("^%a:[/\\]")then return r end;return"C:/Serotonin/files/"..r
end

Fawn.StoragePaths=cpy982(PATHS)
Fawn.SecondaryMetrics=cpy982(SECONDARY)
function Fawn:EnsureStorage()return ensure982()end
function Fawn:GetStoragePaths()return cpy982(PATHS)end
function Fawn:ListStorage(kind)
    kind=tostring(kind or"Configs")
    if kind=="Profiles"or kind=="Profile"then kind="ProfilePictures"elseif kind=="Logos"or kind=="Logo"then kind="LogoPictures"end
    return list982(PATHS[kind]or ROOT,kind=="Configs"and"config"or(kind=="ProfilePictures"or kind=="LogoPictures")and"image"or nil)
end
function Fawn:ResolveStoragePath(kind,name)return resolve982(kind,name)end
ensure982()

local oldProfileImage982=Window.SetProfileImage
function Window:SetProfileImage(v)
    if type(v)=="string"and v~=""then v=resolve982("ProfilePictures",v)end
    return oldProfileImage982(self,v)
end
local oldLogoImage982=Window.SetLogoImage
function Window:SetLogoImage(v)
    if type(v)=="string"and v~=""then v=resolve982("LogoPictures",v)end
    return oldLogoImage982(self,v)
end

-- Hidden/profile-only tabs remain selectable but are omitted from sidebar navigation.
local visibleTabs982=Window._visibleTabs
function Window:_visibleTabs()
    local base=visibleTabs982(self);local out={}
    for _,t in ipairs(base)do if t.sidebarHidden~=true then out[#out+1]=t end end
    return out
end
function Tab:SetSidebarHidden(v)self.sidebarHidden=v~=false;return self end
function Tab:GetSidebarHidden()return self.sidebarHidden==true end

-- Fully authored profile menu. SetProfileMenu() means exactly what the script supplies.
local BUILTIN={
    settings={label="Settings",icon="settings"},
    profile={label="Profile",icon="user"},
    center={label="Center UI",icon="misc"},
    reset={label="Reset UI Position",icon="misc"},
    resetstyle={label="Reset Appearance",icon="image"},
    close={label="Close",icon="misc"},
    destroy={label="Unload UI",icon="misc",danger=true}
}
local DEFAULT_MENU={"settings","profile","center","close"}
local function menuVisible982(item,self)
    local v=item.visible;if type(v)=="function"then local ok,r=pcall(v,self,item);return ok and r~=false end
    return v~=false
end
local function menuEnabled982(item,self)
    local v=item.enabled;if type(v)=="function"then local ok,r=pcall(v,self,item);return ok and r~=false end
    return v~=false
end
local function makeBuiltin982(id,opt)
    local b=BUILTIN[id];if not b then return nil end;opt=type(opt)=="table"and opt or{}
    return{id=id,builtin=id,label=tostring(opt.label or b.label),icon=opt.icon or b.icon,danger=opt.danger~=nil and opt.danger or b.danger,visible=opt.visible,enabled=opt.enabled,closeOnClick=opt.closeOnClick~=false}
end
local function menuItems982(self)
    local source=self.profileMenuExact
    if type(source)~="table"then source=DEFAULT_MENU end
    local out={}
    for _,raw in ipairs(source)do
        local item=nil
        if type(raw)=="string"then item=makeBuiltin982(lower(raw))
        elseif type(raw)=="table"then
            if raw.separator then item={separator=true,label=raw.label,visible=raw.visible}
            elseif raw.builtin then item=makeBuiltin982(lower(tostring(raw.builtin)),raw)
            else item=raw end
        end
        if item and menuVisible982(item,self)then out[#out+1]=item end
    end
    if type(self.profileMenuExact)~="table"then for _,item in ipairs(self.profileMenuItems or{})do if menuVisible982(item,self)then out[#out+1]=item end end end
    return out
end
local oldAddProfile982=Window.AddProfileMenuItem
function Window:AddProfileMenuItem(label,callback,options)
    options=type(options)=="table"and options or{}
    local item={id=options.id,label=tostring(label or"Item"),callback=type(callback)=="function"and callback or nil,icon=options.icon or"misc",danger=options.danger==true,visible=options.visible,enabled=options.enabled,closeOnClick=options.closeOnClick~=false,meta=options.meta}
    self.profileMenuItems=self.profileMenuItems or{};self.profileMenuItems[#self.profileMenuItems+1]=item;return item
end
function Window:AddProfileMenuSeparator(label,opt)
    local item={separator=true,label=label,visible=type(opt)=="table"and opt.visible or nil};self.profileMenuItems=self.profileMenuItems or{};self.profileMenuItems[#self.profileMenuItems+1]=item;return item
end
function Window:AddProfileMenuBuiltin(id,opt)
    local item=makeBuiltin982(lower(tostring(id or"")),opt);if item then self.profileMenuItems=self.profileMenuItems or{};self.profileMenuItems[#self.profileMenuItems+1]=item end;return item
end
function Window:SetProfileMenu(items,opt)
    self.profileMenuExact={};for _,x in ipairs(type(items)=="table"and items or{})do self.profileMenuExact[#self.profileMenuExact+1]=x end
    opt=type(opt)=="table"and opt or{};if opt.title~=nil then self.profileMenuTitle=tostring(opt.title)end;if opt.width~=nil then self.profileMenuWidth=tonumber(opt.width)end
    self.profileMenuScroll=0;return self
end
function Window:UseDefaultProfileMenu(v)if v==false then self.profileMenuExact={}else self.profileMenuExact=nil end;self.profileMenuScroll=0;return self end
function Window:SetProfileMenuTitle(v)self.profileMenuTitle=tostring(v or"");return self end
function Window:SetProfileMenuWidth(v)self.profileMenuWidth=clamp982(tonumber(v)or 261,210,420);return self end
function Window:GetResolvedProfileMenu()return cpy982(menuItems982(self))end
function Window:GetProfileMenuItems()return self.profileMenuExact and cpy982(self.profileMenuExact)or cpy982(self.profileMenuItems or{})end
function Window:RemoveProfileMenuItem(which)
    local list=self.profileMenuExact or self.profileMenuItems or{};local idx=nil
    if type(which)=="number"then idx=which else for i,item in ipairs(list)do if item==which or(type(item)=="table"and(item.id==which or item.label==which))then idx=i break end end end
    if idx and list[idx]then table.remove(list,idx)end;return self
end
function Window:ClearProfileMenuItems()self.profileMenuItems={};if self.profileMenuExact then self.profileMenuExact={}end;return self end
function Window:GetGlassTintStrength()return tonumber(self.glassTintStrength)or 0 end

local function accountRect982(self)
    local s=self.scale;local _,profileY=self:_sidebarGeometry();local items=menuItems982(self);local title=self.profileMenuTitle;if title==nil then title="ACCOUNT"end
    local header=title~=""and 38*s or 10*s;local total=header+10*s
    for _,it in ipairs(items)do total=total+(it.separator and 22*s or 38*s)end
    local maxH=max(96*s,profileY-(self.y+12*s)-8*s);local h=min(total,maxH);local w=clamp982(tonumber(self.profileMenuWidth)or 261,210,420)*s
    local p={x=self.x+7*s,w=w,h=h,y=profileY-h-8*s,items=items,header=header,total=total,maxScroll=max(0,total-h)}
    self:_clampPopup(p);self._profilePopupRect=p;return p
end
function Window:_accountPopupRect()return accountRect982(self)end
local function runBuiltin982(self,id,item)
    if id=="settings"then local sp=Fawn:CreateSettingsPage(self,{showInSidebar=false});if sp and sp.Tab then sp.Tab.sidebarHidden=true;self:SelectTab(sp.Tab)end
    elseif id=="profile"then if type(self.profileMenuProfileAction)=="function"then pcall(self.profileMenuProfileAction,self,item)elseif type(self.profileClick)=="function"then pcall(self.profileClick,self)end
    elseif id=="center"or id=="reset"then self:Center()
    elseif id=="resetstyle"then if type(self.ResetPolish)=="function"then self:ResetPolish()end;self:SetTheme("Modern Blue"):SetScale(1):SetOutlineStrength(1)
    elseif id=="destroy"then self:Destroy()
    elseif id=="close"then end
end
function Window:_drawAccountPopup()
    if not self.accountOpen then self._profilePopupRect=nil return end
    local s=self.scale;local p=accountRect982(self);self:_popupFrame(p)
    local title=self.profileMenuTitle;if title==nil then title="ACCOUNT"end
    if title~=""then textC(upper(title),p.x+SECONDARY.Padding*s,p.y+20*s,self:_color("muted"),13*s,"Verdana")end
    if p.maxScroll>0 and self:_hit(p.x,p.y,p.w,p.h)and Input.wheel~=0 then self.profileMenuScroll=clamp982((self.profileMenuScroll or 0)+Input.wheel*34*s,0,p.maxScroll)end
    self.profileMenuScroll=clamp982(self.profileMenuScroll or 0,0,p.maxScroll)
    local y=p.y+p.header-(self.profileMenuScroll or 0);local bottom=p.y+p.h-6*s
    for _,it in ipairs(p.items)do
        if it.separator then
            local rh=22*s;if y>=p.y+p.header-rh and y+rh<=bottom then local yy=y+rh*.5;line(p.x+SECONDARY.Padding*s,yy,p.x+p.w-SECONDARY.Padding*s,yy,self:_color("line"),1,32);if it.label and tostring(it.label)~=""then textC(upper(tostring(it.label)),p.x+SECONDARY.Padding*s,yy-7*s,self:_color("muted"),10*s,"Verdana")end end;y=y+rh
        else
            local rh=38*s;local drawRow=y>=p.y+p.header-rh and y+rh<=bottom;local enabled=menuEnabled982(it,self)
            if drawRow then
                local hx=p.x+6*s;local hw=p.w-12*s;local hov=enabled and self:_hit(hx,y,hw,rh-4*s)
                if hov then self:_fill("control",hx,y,hw,rh-4*s,"controlHover",7*s)end
                self:_icon(it.icon or"misc",p.x+22*s,y+(rh-4*s)*.5,14*s,enabled and(hov and"accent"or"icon")or"muted")
                local col=it.danger and self:_color("danger")or self:_color(enabled and"text"or"muted")
                textC(fit(tostring(it.label or"Item"),p.w-62*s,15*s,"Verdana"),p.x+40*s,y+(rh-4*s)*.5,col,15*s,"Verdana")
                if Input.click and not self._consumed and hov then
                    if it.builtin then runBuiltin982(self,it.builtin,it)elseif type(it.callback)=="function"then pcall(it.callback,self,it)end
                    if it.closeOnClick~=false then self.accountOpen=false end;self:_consume()
                end
            end;y=y+rh
        end
    end
    if p.maxScroll>0 then local tx=p.x+p.w-7*s;local trackTop=p.y+p.header;local trackH=max(10,p.h-p.header-8*s);local thumb=max(24*s,trackH*(p.h/p.total));local span=max(1,trackH-thumb);local ty=trackTop+span*((self.profileMenuScroll or 0)/p.maxScroll);rect(tx,trackTop,2*s,trackH,self:_color("control"),1*s,100);rect(tx-1*s,ty,4*s,thumb,self:_color("outline"),2*s,180)end
end

-- Save/load now owns the Fawn Modern storage root and preserves custom theme colors/assets.
function SettingsPage:SetConfigPath(p)self.ConfigPath=relConfig982(p);return self end
function SettingsPage:GetConfigPath()return self.ConfigPath end
function SettingsPage:SaveConfig()
    ensure982();local f=fs982();if not f or type(f.write)~="function"then self.Window:Notify("File API unavailable",{title="CONFIG"});return false end
    local path=fullConfig982(self.ConfigPath);local dir=path:match("^(.*)/[^/]+$");if dir then mkdir982(dir)end
    local ok,wrote=pcall(f.write,path,"return "..serialize(self.Window:GetConfig()));local good=ok and wrote~=false
    self.Window:Notify(good and("Saved "..basename982(path))or"Config save failed",{title="CONFIG"});return good
end
function SettingsPage:LoadConfig()
    ensure982();local f=fs982();if not f or type(f.read)~="function"then self.Window:Notify("File API unavailable",{title="CONFIG"});return false end
    local path=fullConfig982(self.ConfigPath);local ok,str=pcall(f.read,path);if not ok or type(str)~="string"or str==""then self.Window:Notify("Config file not found",{title="CONFIG"});return false end
    local fn=loadfn(str);if not fn then self.Window:Notify("Config compile failed",{title="CONFIG"});return false end
    local ok2,data=pcall(fn);if not ok2 or type(data)~="table"then self.Window:Notify("Config data invalid",{title="CONFIG"});return false end
    self.Window:LoadConfig(data);self.Window:Notify("Loaded "..basename982(path),{title="CONFIG"});return true
end
function SettingsPage:ShowConfigPath()local p=fullConfig982(self.ConfigPath);self.Window:Notify(p,{title="CONFIG PATH",duration=6});return p end
function SettingsPage:ListConfigs()return list982(PATHS.Configs,"config")end
function SettingsPage:ListProfilePictures()return list982(PATHS.ProfilePictures,"image")end
function SettingsPage:ListLogoPictures()return list982(PATHS.LogoPictures,"image")end
function SettingsPage:RefreshBrowsers()
    local function opts(list,empty)local q={}for _,x in ipairs(list)do q[#q+1]=x end;if #q==0 then q[1]=empty end;return q end
    if self.Controls.ConfigBrowser then self.Controls.ConfigBrowser:SetOptions(opts(self:ListConfigs(),"(no config files)"),{preserve="text"})end
    if self.Controls.ProfileBrowser then self.Controls.ProfileBrowser:SetOptions(opts(self:ListProfilePictures(),"(no profile pictures)"),{preserve="text"})end
    if self.Controls.LogoBrowser then self.Controls.LogoBrowser:SetOptions(opts(self:ListLogoPictures(),"(no logo pictures)"),{preserve="text"})end
    return self
end

local getCfg982=Window.GetConfig
function Window:GetConfig()
    local q=getCfg982(self);q.themeColors=cpy982(self.theme);q.assets={profileImage=self.profileImagePath,logoImage=self.logoImagePath};q.profile={name=self.profileName,subtitle=self.profileSubtitle,brand=self.brand,brandSubtitle=self.subtitle};return q
end
local loadCfg982=Window.LoadConfig
function Window:LoadConfig(cfg,silent)
    loadCfg982(self,cfg,silent)
    if type(cfg)=="table"then
        if type(cfg.themeColors)=="table"then self.theme=cpy982(cfg.themeColors);self.themeName="Custom";if self.theme.outline then self.outlineColor=cpy982(self.theme.outline)end end
        if type(cfg.profile)=="table"then if cfg.profile.name~=nil then self:SetProfileName(cfg.profile.name)end;if cfg.profile.subtitle~=nil then self:SetProfileSubtitle(cfg.profile.subtitle)end;if cfg.profile.brand~=nil then self.brand=tostring(cfg.profile.brand)end;if cfg.profile.brandSubtitle~=nil then self.subtitle=tostring(cfg.profile.brandSubtitle)end end
        if type(cfg.assets)=="table"then if cfg.assets.profileImage and cfg.assets.profileImage~=""then self:SetProfileImage(cfg.assets.profileImage)end;if cfg.assets.logoImage and cfg.assets.logoImage~=""then self:SetLogoImage(cfg.assets.logoImage)end end
    end
    return self
end

-- New Settings implementation: materials live in Appearance, file browsing is native to Settings,
-- and showInSidebar=false creates a profile-menu-only settings page.
function Fawn:CreateSettingsPage(window,opt)
    if window==self then window,opt=opt,nil end
    if kind(window)~="Window"and kind(window)~="Panel"then error("CreateSettingsPage requires a Fawn Window")end
    if window.settingsPage then return window.settingsPage end
    ensure982();opt=type(opt)=="table"and opt or{}
    local page=setmetatable({Window=window,Controls={},ConfigPath=relConfig982(opt.configPath or"default.lua"),Defaults=nil},SettingsPage)
    local tab=window:Tab(opt.title or"Settings",{group=opt.group or"MISCELLANEOUS",icon="settings"});page.Tab=tab;tab.sidebarHidden=opt.showInSidebar==false or opt.profileOnly==true
    local appearance=tab:Section("APPEARANCE",{column=1,row=1,sizeMode="auto"})
    local behavior=tab:Section("BEHAVIOR",{column=2,row=1,sizeMode="auto"})
    local profile=tab:Section("PROFILE & BRAND",{column=1,row=2,sizeMode="auto"})
    local config=tab:Section("CONFIGURATION",{column=2,row=2,sizeMode="auto"})
    local diagnostics=tab:Section("DIAGNOSTICS",{column=1,row=3,span=2,columns=2,sizeMode="auto"})
    local ti=indexOf(Fawn.ThemeNames,window:GetThemeName())or 1
    page.Controls.Theme=appearance:Dropdown("Theme",Fawn.ThemeNames,ti,{noConfig=true});page.Controls.Theme:OnChanged(function(v)window:SetTheme(v);if page._syncColors then page:_syncColors()end end)
    page.Controls.Scale=appearance:Slider("UI Scale",55,165,round982(window:GetScale()*100),{noConfig=true,format=function(v)return round982(v).."%"end});page.Controls.Scale:OnChanged(function(v)window:SetScale(v/100)end)
    appearance:AddSeparator("MATERIAL")
    local mats=Fawn.SurfaceStyles or{"Solid","Frosted","Acrylic","Smoke","Clear"};page.Controls.SurfaceStyle=appearance:Dropdown("Surface Material",mats,indexOf(mats,window.GetSurfaceStyle and window:GetSurfaceStyle()or"Solid")or 1,{noConfig=true});page.Controls.SurfaceStyle:OnChanged(function(v)if window.SetSurfaceStyle then window:SetSurfaceStyle(v)end;if page.Controls.Glass then page.Controls.Glass:Set(window:GetLiquidGlass(),true)end end)
    page.Controls.Glass=appearance:Toggle("Liquid Glass",window:GetLiquidGlass(),{noConfig=true});page.Controls.Glass:OnChanged(function(v)window:SetLiquidGlass(v);if page.Controls.SurfaceStyle and window.GetSurfaceStyle then page.Controls.SurfaceStyle:Set(window:GetSurfaceStyle(),true)end end)
    page.Controls.GlassOpacity=appearance:Slider("Glass Opacity",18,100,round982(window:GetGlassOpacity()*100),{noConfig=true,format=function(v)return round982(v).."%"end});page.Controls.GlassOpacity:OnChanged(function(v)window:SetGlassOpacity(v/100)end)
    if window.GetGlassTint then page.Controls.GlassTint=appearance:ColorPicker("Glass Tint",window:GetGlassTint(),{noConfig=true});page.Controls.GlassTint:OnChanged(function(v)window:SetGlassTint(v)end)end
    if window.GetGlassTintStrength then page.Controls.GlassTintStrength=appearance:Slider("Tint Strength",0,65,round982(window:GetGlassTintStrength()*100),{noConfig=true,format=function(v)return round982(v).."%"end});page.Controls.GlassTintStrength:OnChanged(function(v)window:SetGlassTintStrength(v/100)end)end
    if window.SetSurfaceHighlights then page.Controls.SurfaceHighlights=appearance:Toggle("Glass Highlights",window.surfaceHighlights~=false,{noConfig=true});page.Controls.SurfaceHighlights:OnChanged(function(v)window:SetSurfaceHighlights(v)end)end
    appearance:AddSeparator("GEOMETRY & OUTLINE")
    local corners=Fawn.CornerPresets or{"Square","Tight","Soft","Round"};page.Controls.CornerPreset=appearance:Dropdown("Corner Preset",corners,indexOf(corners,"Round")or 1,{noConfig=true});page.Controls.CornerPreset:OnChanged(function(v)if window.SetCornerPreset then window:SetCornerPreset(v)end end)
    if window.SetRadiusScale then page.Controls.RadiusScale=appearance:Slider("Radius Scale",45,165,round982((window.radiusScale or 1)*100),{noConfig=true,format=function(v)return round982(v).."%"end});page.Controls.RadiusScale:OnChanged(function(v)window:SetRadiusScale(v/100)end)end
    page.Controls.Outline=appearance:ColorPicker("Outline",window:GetOutlineColor(),{noConfig=true});page.Controls.Outline:OnChanged(function(v)window:SetOutlineColor(v);window:SetThemeColor("outline",v,true)end)
    page.Controls.OutlineStrength=appearance:Slider("Outline Thickness",25,300,round982(window:GetOutlineStrength()*100),{noConfig=true,format=function(v)return format("%.2fx",v/100)end});page.Controls.OutlineStrength:OnChanged(function(v)window:SetOutlineStrength(v/100)end)
    if window.SetOutlineOpacity then page.Controls.OutlineOpacity=appearance:Slider("Outline Opacity",15,100,round982((window.outlineOpacity or 1)*100),{noConfig=true,format=function(v)return round982(v).."%"end});page.Controls.OutlineOpacity:OnChanged(function(v)window:SetOutlineOpacity(v/100)end)end
    appearance:AddSeparator("COLORS")
    local colorDefs={{"Accent","accent"},{"Main Background","menuBg"},{"Card Background","card"},{"Control Background","control"},{"Control Hover","controlHover"},{"Active Item","activeItem"},{"Text","text"},{"Muted Text","muted"},{"Navigation Text","navText"},{"Popup","popup"},{"Avatar","avatar"},{"Danger","danger"},{"Success","success"},{"Warning","warning"}}
    page.ColorControls={}
    for _,d in ipairs(colorDefs)do local cp=appearance:ColorPicker(d[1],window:_color(d[2]),{noConfig=true});cp:OnChanged(function(v)window:SetThemeColor(d[2],v,true);if d[2]=="outline"then window:SetOutlineColor(v)end end);page.ColorControls[d[2]]=cp end
    function page:_syncColors()for k,c in pairs(self.ColorControls or{})do c:Set(window:_color(k),true)end;if self.Controls.Outline then self.Controls.Outline:Set(window:GetOutlineColor(),true)end end
    appearance:AddButton("Reset Appearance",function()window:SetTheme("Modern Blue"):SetScale(1):SetLiquidGlass(false):SetOutlineStrength(1);if window.ResetPolish then window:ResetPolish()end;page:_syncColors()end)

    page.Controls.Smooth=behavior:Toggle("Smooth Scrolling",window.smoothScroll,{noConfig=true});page.Controls.Smooth:OnChanged(function(v)window:SetSmoothScroll(v)end)
    page.Controls.Anim=behavior:Toggle("Animations",window.animations,{noConfig=true});page.Controls.Anim:OnChanged(function(v)window:SetAnimations(v)end)
    if window.SetMotionStyle then local motions=Fawn.MotionStyles or{"Off","Minimal","Smooth","Snappy","Fluid"};page.Controls.MotionStyle=behavior:Dropdown("Animation Style",motions,indexOf(motions,window.motionStyle or"Smooth")or 1,{noConfig=true});page.Controls.MotionStyle:OnChanged(function(v)window:SetMotionStyle(v)end)end
    page.Controls.MotionSpeed=behavior:Slider("Animation Speed",4,30,round982(window.animationSpeed or 10),{noConfig=true});page.Controls.MotionSpeed:OnChanged(function(v)window:SetAnimationSpeed(v)end)
    if window.SetHoverAnimations then page.Controls.HoverAnimations=behavior:Toggle("Animated Hovers",window.hoverAnimations~=false,{noConfig=true});page.Controls.HoverAnimations:OnChanged(function(v)window:SetHoverAnimations(v)end)end
    if window.SetSwitchAnimations then page.Controls.SwitchAnimations=behavior:Toggle("Animated Switches",window.switchAnimations~=false,{noConfig=true});page.Controls.SwitchAnimations:OnChanged(function(v)window:SetSwitchAnimations(v)end)end
    page.Controls.ScrollSpeed=behavior:Slider("Scroll Speed",1,30,window:GetScrollSpeed(),{noConfig=true});page.Controls.ScrollSpeed:OnChanged(function(v)window:SetScrollSpeed(v)end)
    local np=indexOf(Fawn.NotificationPositions,window:GetNotificationPosition())or 4;page.Controls.Notifications=behavior:Dropdown("Notification Corner",Fawn.NotificationPositions,np,{noConfig=true});page.Controls.Notifications:OnChanged(function(v)window:SetNotificationPosition(v)end)
    page.Controls.MenuKey=behavior:Keybind("Menu Key",window.toggleKey,{label=window.toggleLabel,mode="Toggle",keyboardOnly=true,keybindList=false,noConfig=true});page.Controls.MenuKey:OnKeyChanged(function(k,l)window:SetToggleKey(k,l)end)
    behavior:AddButtonPair("Center UI",function()window:Center()end,"Default Size",function()window:SetSize(REF.Width,REF.Height)end)

    page.Controls.ProfileName=profile:Input("Username",window.profileName,{placeholder="User",noConfig=true});page.Controls.ProfileName:OnChanged(function(v)window:SetProfileName(v)end)
    page.Controls.ProfileSub=profile:Input("Subtitle",window.profileSubtitle,{placeholder="Developer",noConfig=true});page.Controls.ProfileSub:OnChanged(function(v)window:SetProfileSubtitle(v)end)
    profile:AddSeparator("PROFILE PICTURE")
    local pfiles=page:ListProfilePictures();if #pfiles==0 then pfiles={"(no profile pictures)"}end
    page.Controls.ProfileBrowser=profile:Dropdown("Profile Picture",pfiles,1,{noConfig=true});page.Controls.ProfileBrowser:OnChanged(function(v)if v and v:sub(1,1)~="("then window:SetProfileImage(v)end end)
    profile:AddButtonPair("Refresh Pictures",function()page:RefreshBrowsers()end,"Clear Avatar",function()window:ClearProfileImage()end)
    page.Controls.ProfilePath=profile:Input("Profile file",window.profileImagePath and basename982(window.profileImagePath)or"",{placeholder="avatar.png",noConfig=true,maxLength=260});profile:AddButton("Apply Profile File",function()window:SetProfileImage(page.Controls.ProfilePath:Get())end)
    profile:AddSeparator("BRAND & LOGO")
    page.Controls.Brand=profile:Input("Brand Title",window.brand,{noConfig=true});page.Controls.Brand:OnChanged(function(v)window.brand=v end)
    page.Controls.Subtitle=profile:Input("Brand Subtitle",window.subtitle,{noConfig=true});page.Controls.Subtitle:OnChanged(function(v)window.subtitle=v end)
    local lfiles=page:ListLogoPictures();if #lfiles==0 then lfiles={"(no logo pictures)"}end
    page.Controls.LogoBrowser=profile:Dropdown("Logo Picture",lfiles,1,{noConfig=true});page.Controls.LogoBrowser:OnChanged(function(v)if v and v:sub(1,1)~="("then window:SetLogoImage(v)end end)
    profile:AddButtonPair("Refresh Logos",function()page:RefreshBrowsers()end,"Clear Logo",function()window:ClearLogoImage()end)
    page.Controls.LogoPath=profile:Input("Logo file",window.logoImagePath and basename982(window.logoImagePath)or"",{placeholder="logo.png",noConfig=true,maxLength=260});profile:AddButton("Apply Logo File",function()window:SetLogoImage(page.Controls.LogoPath:Get())end)

    local cfgs=page:ListConfigs();if #cfgs==0 then cfgs={"(no config files)"}end
    page.Controls.ConfigBrowser=config:Dropdown("Config File",cfgs,1,{noConfig=true});page.Controls.ConfigBrowser:OnChanged(function(v)if v and v:sub(1,1)~="("then page:SetConfigPath(v)end end)
    page.Controls.ConfigName=config:Input("New Config Name","default.lua",{placeholder="default.lua",noConfig=true,maxLength=96})
    config:AddButtonPair("Save As",function()page:SetConfigPath(page.Controls.ConfigName:Get());page:SaveConfig();page:RefreshBrowsers()end,"Load Selected",function()local v=page.Controls.ConfigBrowser:Get();if v and v:sub(1,1)~="("then page:SetConfigPath(v);page:LoadConfig()end end)
    config:AddButtonPair("Refresh Files",function()page:RefreshBrowsers()end,"Show Path",function()page:ShowConfigPath()end)
    config:AddSeparator("IN-MEMORY PROFILES")
    config:AddButtonPair("Save Current",function()window:SaveNamedConfig(window.configName);window:Notify("Named config saved",{title="CONFIG"})end,"Duplicate",function()local n=window:DuplicateNamedConfig();window:Notify("Created "..n,{title="CONFIG"})end)
    config:AddValue("Configs Folder",REL.Configs,{muted=true,wrap=true,maxLines=2})

    diagnostics:AddValue("Paint Frames",function()return Fawn:GetPaintCount()end,{controlColumn=1});diagnostics:AddValue("Paint Errors",function()return Fawn:GetPaintErrors()end,{controlColumn=1})
    diagnostics:AddValue("Draw Errors",function()return E.drawErrors end,{controlColumn=2});diagnostics:AddValue("Window Size",function()local w,h=window:GetSize();return round982(w).." x "..round982(h)end,{controlColumn=2});diagnostics:AddValue("Scale",function()return round982(window:GetScale()*100).."%"end,{controlColumn=2})
    diagnostics:AddButton("Test Notification",function()window:Notify("Fawn Modern secondary UI spacing + notification accent test.",{title="DIAGNOSTICS"})end,{controlColumn=2})
    page:CaptureDefaults();window.settingsPage=page;page:RefreshBrowsers();return page
end

-- Keep rounded Section geometry even when a page clip cuts through the card. Also avoid the
-- translucent scrollbar-gutter repaint that produced darker edge strips in Liquid Glass.
function Window:_drawSection(box,bodyTop,bodyBottom,bodyLeft,bodyRight)
    local sec=box.section;local s=self.scale;local cardTop=box.cardY;local cardBottom=cardTop+box.cardH
    local clipL=max(bodyLeft or box.x,box.x);local clipR=min(bodyRight or(box.x+box.w),box.x+box.w);local clipT=max(bodyTop,cardTop);local clipB=min(bodyBottom,cardBottom)
    if clipB<=clipT or clipR<=clipL then return end
    if sec._scrollDrag then if Input.left and sec.maxScroll>0 then local rr=snapRatio96((Input.my-sec._scrollDrag.top-sec._scrollDrag.off)/max(1,sec._scrollDrag.span));sec.scrollTarget=rr*sec.maxScroll;sec.scroll=sec.scrollTarget else sec._scrollDrag=nil;sec.scroll,sec.scrollTarget=settle96(sec.scroll,sec.scrollTarget,sec.maxScroll,self.scrollSpeed,s,false)end else sec.scroll,sec.scrollTarget=settle96(sec.scroll,sec.scrollTarget,sec.maxScroll,self.scrollSpeed,s,false)end
    local rr=min(14*s,(clipB-clipT)*.5,(clipR-clipL)*.5);self:_fill("card",clipL,clipT,clipR-clipL,clipB-clipT,"card",rr)
    local rows={}for c,r in pairs(box.layouts)do rows[#rows+1]={c=c,r=r}end;sort(rows,function(a,b)if a.r.y==b.r.y then return a.r.x<b.r.x end return a.r.y<b.r.y end);local offset=sec.scroll or 0
    for _,q in ipairs(rows)do local r={x=q.r.x,y=q.r.y-offset,w=q.r.w,h=q.r.h};if r.y>=clipT-.25 and r.y+r.h<=clipB+.25 and r.x>=clipL-.25 and r.x+r.w<=clipR+.25 then self:_drawControl(q.c,r,clipT,clipB)end end
    if sec.columnDividers==true and sec.columns and sec.columns>1 then local gap=(sec.controlGap or 12)*s;local usable=box.w-(((sec.sizeMode=="fixed"or sec.sizeMode=="fill"or sec.maxHeight)and REF.SectionScrollbarGutter or 0)*s);local cw=(usable-gap*(sec.columns-1))/sec.columns;for i=1,sec.columns-1 do local x=box.x+i*cw+(i-.5)*gap;local y1=max(clipT+8*s,cardTop+8*s);local y2=min(clipB-8*s,cardBottom-8*s);if y2>y1 then line(x,y1,x,y2,self:_color("line"),1,14)end end end
    if sec.maxScroll>1 then
        local gutter=REF.SectionScrollbarGutter*s;local gx=box.x+box.w-gutter;local tx=gx+gutter*.5;local top=clipT+9*s;local bh=max(1,clipB-clipT-18*s);local thumb=max(28*s,bh*(box.cardH/max(box.cardH,box.contentH)));local span=max(1,bh-thumb);local ratio=sec.maxScroll>0 and snapRatio96((sec.scroll or 0)/sec.maxScroll)or 0;local ty=top+span*ratio;local trackHover=self:_hit(gx,clipT,gutter,clipB-clipT);local thumbHover=self:_hit(gx,ty-3*s,gutter,thumb+6*s);local active=sec._scrollDrag~=nil
        if trackHover or active then rect(tx-1*s,top,2*s,bh,self:_color("controlHover"),1*s,88)end;rect(tx-((active or thumbHover)and 2*s or 1.5*s),ty,(active or thumbHover)and 4*s or 3*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 180)
        if Input.click and not self._consumed and not self:_hasPopup()and thumbHover then sec._scrollDrag={top=top,span=span,off=Input.my-ty};self:_consume()end
    else sec._scrollDrag=nil;sec.scroll,sec.scrollTarget=0,0 end
    self:_out(clipL,clipT,clipR-clipL,clipB-clipT,rr,.82,self:_color("outline"),112)
    local titleY=box.y+7*s;if titleY>=bodyTop-20*s and titleY<=bodyBottom and box.x>=bodyLeft-1 and box.x<=(bodyRight or box.x+box.w)then textC(fit(upper(sec.name),max(20,box.w-44*s),14*s,"Verdana"),box.x+22*s,titleY,self:_color("muted"),14*s,"Verdana")end
end

-- ESP element capture gets a larger hit target, wins over standalone frame dragging while active,
-- and keeps pointer ownership for the entire drag.
local espHit982=ESPPreview._hitESP
function ESPPreview:SetElementDragPadding(v)self.elementDragPadding=clamp982(tonumber(v)or 6,0,20);return self end
function ESPPreview:_hitESP(mx,my,x,y,w,h)
    local s=self.window and self.window.scale or 1;local p=(self.elementDragPadding or 6)*s
    return mx>=x-p and mx<x+w+p and my>=y-p and my<y+h+p
end
local espRender982=ESPPreview._render
function ESPPreview:_render()
    if self.docked or not self.visible or self.destroyed then return end
    local s=overlayScale(self);local w=self.width*s;local h=self.height*s
    self:_drawBody(self.x,self.y,w,h,false)
    if self._espDrag then E.pointerConsumed=true;return end
    self:_drag(self.x,self.y,w,h,42*s)
end

-- Secondary frames share one padding/radius contract; header dividers never touch rounded corners.
function Window:_popupFrame(p)
    local s=self.scale;local r=SECONDARY.Radius*s;self:_fill("popup",p.x,p.y,p.w,p.h,"popup",r);self:_out(p.x,p.y,p.w,p.h,r,.9,self:_color("outline"),145)
end
if Overlay then
function Overlay:_frame(x,y,w,h,header)
    local s=overlayScale(self);local win=self.window;local r=SECONDARY.Radius*s
    if win then win:_fill("overlay",x,y,w,h,"popup",r);win:_out(x,y,w,h,r,.9,win.outlineColor or self:_theme("outline"),145)
    else rect(x,y,w,h,self:_theme("popup"),r,245);outline(x,y,w,h,self:_theme("outline"),r,145,max(.8,s))end
    if header then local inset=SECONDARY.HeaderInset*s;line(x+inset,y+header,x+w-inset,y+header,self:_theme("line"),max(.75,s*.7),38)end
end
end

-- Notification accent is an inset pill, so it belongs to the card instead of cutting through its radius.
function Notification:_render(index)
    if self.dismissed or self.destroyed then return false end;local now=nowMs();if now>=self.expires then self.dismissed=true;return false end
    local win=self.window;local s=win and win.scale or 1;local w=self.width*s;local pad=14*s;local accentGap=9*s;local textXPad=pad+7*s
    local titleH=self.title~=""and 21*s or 0;local maxText=max(40,w-textXPad-pad);local lines=self.wrap~=false and wrapText(self.text,maxText,14*s,"Verdana",self.maxLines)or{fit(self.text,maxText,14*s,"Verdana")};local lh=18*s;local h=pad*2+titleH+#lines*lh
    local x,y=notificationAnchor(self.position,w,h,index,8*s);local t=win and win.theme or MODERN;local r=SECONDARY.Radius*s
    if win then win:_fill("overlay",x,y,w,h,"popup",r);win:_out(x,y,w,h,r,.9,win.outlineColor or t.outline,145)else rect(x,y,w,h,t.popup,r,245);outline(x,y,w,h,t.outline,r,145,max(.8,s))end
    local ah=max(8*s,h-accentGap*2);rect(x+accentGap,y+accentGap,3*s,ah,t.accent,1.5*s,245)
    local yy=y+pad;if self.title~=""then text(self.title,x+textXPad,yy,t.text,14*s,"Verdana");yy=yy+titleH end;for i,l in ipairs(lines)do text(l,x+textXPad,yy+(i-1)*lh,t.navText,14*s,"Verdana")end;return true
end

-- Main render only changes popup hit-testing: profile menu bounds are dynamic now.
function Window:_render()
    if self.destroyed then return end
    if self._pendingScale then local q=self._pendingScale;self._pendingScale=nil;self._inRender=false;self:SetScale(q)end
    self:_toggleByKey();self:_processKeybinds();self:_processBindCapture();self:_processInputEdit();self:_processSliderEdit();if not self.visible then return end
    self._inRender=true;self._consumed=false;self:_updateWindowDragResize();local s=self.scale;local X,Y=self.x,self.y;local W,H=self.width*s,self.height*s;local I=Fawn.GetInputState and Fawn:GetInputState()or{}
    if (I.click or I.rightClick)and not self._consumed and self:_hasPopup()then
        local inside=false;for _,p in pairs({self.openDrop,self.extraPopup,self.keyMenu,self.colorPopup,self.colorMenu,self.configPopup,self.groupPopup})do
            if p then
                if p.x and p.y and p.w and p.h and self:_hit(p.x,p.y,p.w,p.h)then inside=true break end
                local ch=p.child
                if ch and ch.x and ch.y and ch.w and ch.h and self:_hit(ch.x,ch.y,ch.w,ch.h)then inside=true break end
                if p.triggerX and p.triggerY and p.triggerW and p.triggerH and self:_hit(p.triggerX,p.triggerY,p.triggerW,p.triggerH)then inside=true break end
            end
        end
        if self.accountOpen then local p=self._profilePopupRect or accountRect982(self);local _,py=self:_sidebarGeometry();if self:_hit(p.x,p.y,p.w,p.h)or self:_hit(X+15*s,py,245*s,55*s)then inside=true end end
        if self.searchOpen then local sw=310*s;local sx=X+(self.width-(REF.RightMargin or 32))*s-sw;local sy=Y+78*s;if self:_hit(sx,sy,sw,44*s)then inside=true end end
        if not inside then self:_closePopups();self:_consume()end
    end
    self:_fill("main",X,Y,W,H,"menuBg",(self.corner or 22)*s);self:_drawContent();if self.kind=="Panel"or self.tabBarVisible==false then self:_drawPanelHeader()else self:_drawSidebar();self:_drawTopbar()end
    self:_out(X,Y,W,H,(self.corner or 22)*s,self.borderThickness,self.outlineColor,255)
    if self._drawExtraPopup then self:_drawExtraPopup()end;self:_drawDropdownPopup();self:_drawKeyMenu();self:_drawColorPopup();if self._drawColorMenu then self:_drawColorMenu()end;self:_drawConfigPopup();self:_drawGroupPopup();self:_drawAccountPopup();self:_drawSearchPopup();self._inRender=false
end
-- numeric build identity intentionally omitted
-- numeric build identity intentionally omitted
-- numeric build identity intentionally omitted
-- numeric build identity intentionally omitted
Fawn.DynamicCapabilities=Fawn.DynamicCapabilities or{}
Fawn.DynamicCapabilities.ProfileMenuAuthoring=true
Fawn.DynamicCapabilities.ManagedStorage=true
Fawn.DynamicCapabilities.SettingsFileBrowser=true
Fawn.DynamicCapabilities.ThemeColorEditor=true
Fawn.DynamicCapabilities.HiddenSettingsTab=true
Fawn.DynamicCapabilities.RoundedClippedSections=true
Fawn.DynamicCapabilities.InsetNotificationAccent=true
Fawn.Runtime=Fawn.Runtime or{}
Fawn.Runtime.StorageRoot=ROOT
Fawn.Runtime.ProfileMenu="fully authored built-ins/custom rows/separators + dynamic sizing/scroll"
Fawn.Runtime.SecondaryUI="uniform popup/overlay padding, inset dividers and rounded notification accents"
Fawn.Runtime.ContainerCorners="rounded visible slices + corrected row boundary clipping + no translucent scrollbar gutter overdraw"
Fawn.Runtime.ESPElementDrag="expanded hit targets + drag capture wins over frame drag"
end
__fawn_apply_982(Fawn)
end


-- Fawn Modern preset-settings + sandbox-correct managed storage pass.
do local function __fawn_apply_983(Fawn)
local Window=assert(Fawn.Classes and Fawn.Classes.Window,"Fawn Window class missing")
local SettingsPage=assert(Fawn.Classes and Fawn.Classes.SettingsPage,"Fawn SettingsPage class missing")
local ROOT="Fawn Modern"
local PATHS={Root=ROOT,Configs=ROOT.."/configs",ProfilePictures=ROOT.."/Profile Pictures",LogoPictures=ROOT.."/logo pictures"}
local function cp983(v,seen)
    if type(v)~="table"then return v end
    seen=seen or{};if seen[v]then return seen[v]end
    local q={};seen[v]=q;for k,x in pairs(v)do q[cp983(k,seen)]=cp983(x,seen)end;return q
end
local function fs983()return type(file)=="table"and file or nil end
local function mkdir983(path)
    local f=fs983();if not f then return false end
    for _,n in ipairs{"mkdir","Mkdir","MakeDirectory","makeDirectory","CreateDirectory","createDirectory"}do
        if type(f[n])=="function"then local ok,r=pcall(f[n],path);if ok and r~=false then return true end end
    end
    return false
end
local function ensure983()
    mkdir983(ROOT);mkdir983(PATHS.Configs);mkdir983(PATHS.ProfilePictures);mkdir983(PATHS.LogoPictures)
    return cp983(PATHS)
end
local function base983(p)p=tostring(p or""):gsub("\\","/"):gsub("/+$","");return p:match("([^/]+)$")or p end
local function ext983(p)return lower((tostring(p or""):match("%.([^%.%/\\]+)$")or""))end
local function list983(path,kind)
    ensure983();local f=fs983();if not f then return{}end;local raw
    for _,n in ipairs{"list","List","listdir","ListDir","ListDirectory","listFiles","ListFiles","listfiles","GetFiles","getFiles","getfiles","enumerate","Enumerate","ls"}do
        if type(f[n])=="function"then local ok,r=pcall(f[n],path);if ok and(type(r)=="table"or type(r)=="string")then raw=r;break end end
    end
    local out,seen={},{}
    local function add(v)
        if type(v)=="table"then v=v.path or v.Path or v.name or v.Name or v.file or v.File end
        if type(v)~="string"then return end
        local n=base983(v);if n==""or seen[n]then return end
        local e=ext983(n)
        if kind=="image"and not(e=="png"or e=="jpg"or e=="jpeg"or e=="bmp"or e=="webp")then return end
        if kind=="config"and not(e=="lua"or e=="cfg"or e=="txt"or e=="json")then return end
        seen[n]=true;out[#out+1]=n
    end
    if type(raw)=="table"then for k,v in pairs(raw)do if type(k)=="string"and v==true then add(k)else add(v)end end
    elseif type(raw)=="string"then for s in raw:gmatch("[^\r\n]+")do add(s)end end
    sort(out,function(a,b)return lower(a)<lower(b)end);return out
end
local function path983(kind,name)
    name=tostring(name or""):gsub("\\","/")
    if name==""then return""end
    if name:sub(1,#ROOT)==ROOT then return name end
    local base=PATHS[kind]or ROOT
    if name:find("/",1,true)then return name end
    return base.."/"..name
end
local function cfg983(name)
    name=tostring(name or"default.lua"):gsub("\\","/")
    if name==""then name="default.lua"end
    if not name:find("%.[^/]+$")then name=name..".lua"end
    if name:sub(1,#PATHS.Configs)==PATHS.Configs then return name end
    if name:find("/",1,true)then return name end
    return PATHS.Configs.."/"..name
end
local function display983(path)
    local f=fs983();local root=nil
    if f and type(f.root)=="function"then local ok,r=pcall(f.root);if ok and type(r)=="string"and r~=""then root=r:gsub("\\","/"):gsub("/+$","")end end
    return root and(root.."/"..path)or path
end

Fawn.StoragePaths=cp983(PATHS)
function Fawn:EnsureStorage()return ensure983()end
function Fawn:GetStoragePaths()return cp983(PATHS)end
function Fawn:GetStorageDisplayPaths()local q={}for k,v in pairs(PATHS)do q[k]=display983(v)end return q end
function Fawn:ListStorage(kind)
    kind=tostring(kind or"Configs");if kind=="Profiles"or kind=="Profile"then kind="ProfilePictures"elseif kind=="Logos"or kind=="Logo"then kind="LogoPictures"end
    return list983(PATHS[kind]or ROOT,kind=="Configs"and"config"or(kind=="ProfilePictures"or kind=="LogoPictures")and"image"or nil)
end
function Fawn:ResolveStoragePath(kind,name)return path983(kind,name)end
ensure983()

local pimg983=Window.SetProfileImage
function Window:SetProfileImage(v)if type(v)=="string"and v~=""then v=path983("ProfilePictures",v)end return pimg983(self,v)end
local logo983=Window.SetLogoImage
function Window:SetLogoImage(v)if type(v)=="string"and v~=""then v=path983("LogoPictures",v)end return logo983(self,v)end

function SettingsPage:SetConfigPath(p)self.ConfigPath=cfg983(p);return self end
function SettingsPage:GetConfigPath()return self.ConfigPath end
function SettingsPage:SaveConfig()
    ensure983();local f=fs983();if not f or type(f.write)~="function"then self.Window:Notify("File API unavailable",{title="CONFIG"});return false end
    local p=cfg983(self.ConfigPath);self.ConfigPath=p;local ok,wrote=pcall(f.write,p,"return "..serialize(self.Window:GetConfig()));local good=ok and wrote~=false
    self.Window:Notify(good and("Saved "..base983(p))or"Config save failed",{title="CONFIG"});if good and self.RefreshBrowsers then self:RefreshBrowsers()end;return good
end
function SettingsPage:LoadConfig()
    ensure983();local f=fs983();if not f or type(f.read)~="function"then self.Window:Notify("File API unavailable",{title="CONFIG"});return false end
    local p=cfg983(self.ConfigPath);self.ConfigPath=p;local ok,str=pcall(f.read,p);if not ok or type(str)~="string"or str==""then self.Window:Notify("Config file not found",{title="CONFIG"});return false end
    local fn=loadfn(str);if not fn then self.Window:Notify("Config compile failed",{title="CONFIG"});return false end
    local ok2,data=pcall(fn);if not ok2 or type(data)~="table"then self.Window:Notify("Config data invalid",{title="CONFIG"});return false end
    self.Window:LoadConfig(data);self.Window:Notify("Loaded "..base983(p),{title="CONFIG"});return true
end
function SettingsPage:ShowConfigPath()local p=display983(cfg983(self.ConfigPath));self.Window:Notify(p,{title="CONFIG PATH",duration=6});return p end
function SettingsPage:ListConfigs()return list983(PATHS.Configs,"config")end
function SettingsPage:ListProfilePictures()return list983(PATHS.ProfilePictures,"image")end
function SettingsPage:ListLogoPictures()return list983(PATHS.LogoPictures,"image")end

-- Reusable preset settings: hidden from sidebar by default and optionally mounted in the profile menu.
function Fawn:CreatePresetSettingsMenu(window,opt)
    if window==self then window,opt=opt,nil end
    opt=type(opt)=="table"and cp983(opt)or{}
    opt.showInSidebar=opt.showInSidebar==true
    opt.profileOnly=opt.showInSidebar~=true
    opt.title=opt.title or"Settings";opt.group=opt.group or"MISCELLANEOUS";opt.configPath=opt.configPath or"default.lua"
    local page=self:CreateSettingsPage(window,opt)
    if page and page.Tab and opt.showInSidebar~=true then page.Tab.sidebarHidden=true end
    if opt.profileEntry~=false and window and type(window.AddProfileMenuBuiltin)=="function"then
        local item={builtin="settings",label=opt.profileLabel or"Settings",icon=opt.profileIcon or"settings"}
        if opt.profileMenuOnly==true then window:SetProfileMenu({item},{title=opt.profileMenuTitle or"PROFILE",width=opt.profileMenuWidth or 261})
        else
            local exact=window.profileMenuExact
            if type(exact)=="table"then
                local found=false;for _,v in ipairs(exact)do if v=="settings"or(type(v)=="table"and v.builtin=="settings")then found=true break end end
                if not found then exact[#exact+1]=item end
            end
        end
    end
    window.presetSettingsPage=page
    return page
end
function Window:AddPresetSettingsMenu(opt)return Fawn:CreatePresetSettingsMenu(self,opt)end
Window.CreatePresetSettingsMenu=Window.AddPresetSettingsMenu
function Window:GetPresetSettingsMenu()return self.presetSettingsPage or self.settingsPage end
function Window:OpenPresetSettings()
    local p=self:GetPresetSettingsMenu()or self:AddPresetSettingsMenu({profileEntry=false})
    if p and p.Tab then self:SelectTab(p.Tab)end;self.accountOpen=false;return p
end
function Window:AttachSettingsToProfile(opt)
    opt=type(opt)=="table"and opt or{};local p=self:GetPresetSettingsMenu()or self:AddPresetSettingsMenu({profileEntry=false,configPath=opt.configPath})
    local item={builtin="settings",label=opt.label or"Settings",icon=opt.icon or"settings"}
    if opt.only~=false then self:SetProfileMenu({item},{title=opt.title or"PROFILE",width=opt.width or 261})else self:AddProfileMenuBuiltin("settings",item)end
    return p
end

local createWin983=Fawn.CreateWindow
function Fawn:CreateWindow(opt)
    opt=type(opt)=="table"and opt or{};local w=createWin983(self,opt)
    local ps=opt.presetSettings or opt.settingsPreset
    if ps then local q=type(ps)=="table"and cp983(ps)or{};if q.profileMenuOnly==nil then q.profileMenuOnly=true end;w:AddPresetSettingsMenu(q)end
    return w
end
local createPanel983=Fawn.CreatePanel
function Fawn:CreatePanel(opt)
    opt=type(opt)=="table"and opt or{};local w=createPanel983(self,opt)
    local ps=opt.presetSettings or opt.settingsPreset
    if ps then local q=type(ps)=="table"and cp983(ps)or{};if q.profileEntry==nil then q.profileEntry=false end;w:AddPresetSettingsMenu(q)end
    return w
end
-- numeric build identity intentionally omitted
-- numeric build identity intentionally omitted
-- numeric build identity intentionally omitted
-- numeric build identity intentionally omitted
Fawn.DynamicCapabilities=Fawn.DynamicCapabilities or{}
Fawn.DynamicCapabilities.PresetSettingsMenu=true
Fawn.DynamicCapabilities.ProfileMenuAuthoring=true
Fawn.DynamicCapabilities.ManagedStorage=true
Fawn.DynamicCapabilities.SettingsFileBrowser=true
Fawn.Runtime=Fawn.Runtime or{}
Fawn.Runtime.StorageRoot=ROOT
Fawn.Runtime.StoragePaths=cp983(PATHS)
Fawn.Runtime.PresetSettings="Window:AddPresetSettingsMenu / presetSettings window option / profile-only mounting"
Fawn.ProductName="Fawn Modern"
Fawn.DisplayName="Fawn Modern"
Fawn.Namespace="FawnModern"
-- numeric build identity intentionally omitted
end
__fawn_apply_983(Fawn)
end


-- HOTFIX3: restore Section control rendering while preserving rounded visible slices.
-- The previous strict fully-contained-row gate could reject controls on scaled/fractional layouts.
do
local Window=assert(Fawn.Classes and Fawn.Classes.Window,"Fawn Window class missing")
function Window:_drawSection(box,bodyTop,bodyBottom,bodyLeft,bodyRight)
    local sec=box.section
    local s=self.scale
    local cardTop=box.cardY
    local cardBottom=cardTop+box.cardH
    local clipL=max(bodyLeft or box.x,box.x)
    local clipR=min(bodyRight or(box.x+box.w),box.x+box.w)
    local clipT=max(bodyTop,cardTop)
    local clipB=min(bodyBottom,cardBottom)
    if clipB<=clipT or clipR<=clipL then return end

    if sec._scrollDrag then
        if Input.left and sec.maxScroll>0 then
            local rr=snapRatio96((Input.my-sec._scrollDrag.top-sec._scrollDrag.off)/max(1,sec._scrollDrag.span))
            sec.scrollTarget=rr*sec.maxScroll
            sec.scroll=sec.scrollTarget
        else
            sec._scrollDrag=nil
            sec.scroll,sec.scrollTarget=settle96(sec.scroll,sec.scrollTarget,sec.maxScroll,self.scrollSpeed,s,false)
        end
    else
        sec.scroll,sec.scrollTarget=settle96(sec.scroll,sec.scrollTarget,sec.maxScroll,self.scrollSpeed,s,false)
    end

    local rr=min(14*s,(clipB-clipT)*.5,(clipR-clipL)*.5)
    self:_fill("card",clipL,clipT,clipR-clipL,clipB-clipT,"card",rr)

    local rows={}
    for c,r in pairs(box.layouts or{})do rows[#rows+1]={c=c,r=r}end
    sort(rows,function(a,b)if a.r.y==b.r.y then return a.r.x<b.r.x end return a.r.y<b.r.y end)

    local offset=sec.scroll or 0
    for _,q in ipairs(rows)do
        local r={x=q.r.x,y=q.r.y-offset,w=q.r.w,h=q.r.h}
        self:_drawControl(q.c,r,clipT,clipB)
    end

    if sec.columnDividers==true and sec.columns and sec.columns>1 then
        local gap=(sec.controlGap or 12)*s
        local usable=box.w-(((sec.sizeMode=="fixed"or sec.sizeMode=="fill"or sec.maxHeight)and REF.SectionScrollbarGutter or 0)*s)
        local cw=(usable-gap*(sec.columns-1))/sec.columns
        for i=1,sec.columns-1 do
            local x=box.x+i*cw+(i-.5)*gap
            local y1=max(clipT+8*s,cardTop+8*s)
            local y2=min(clipB-8*s,cardBottom-8*s)
            if y2>y1 then line(x,y1,x,y2,self:_color("line"),1,14)end
        end
    end

    if sec.maxScroll>1 then
        local gutter=REF.SectionScrollbarGutter*s
        local gx=box.x+box.w-gutter
        local tx=gx+gutter*.5
        local top=clipT+9*s
        local bh=max(1,clipB-clipT-18*s)
        local thumb=max(28*s,bh*(box.cardH/max(box.cardH,box.contentH)))
        local span=max(1,bh-thumb)
        local ratio=sec.maxScroll>0 and snapRatio96((sec.scroll or 0)/sec.maxScroll)or 0
        local ty=top+span*ratio
        local thumbHover=self:_hit(gx,ty-3*s,gutter,thumb+6*s)
        local trackHover=self:_hit(gx,clipT,gutter,clipB-clipT)
        local active=sec._scrollDrag~=nil
        if trackHover or active then rect(tx-1*s,top,2*s,bh,self:_color("controlHover"),1*s,88)end
        rect(tx-((active or thumbHover)and 2*s or 1.5*s),ty,(active or thumbHover)and 4*s or 3*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 180)
        if Input.click and not self._consumed and not self:_hasPopup()and thumbHover then
            sec._scrollDrag={top=top,span=span,off=Input.my-ty}
            self:_consume()
        end
    else
        sec._scrollDrag=nil
        sec.scroll,sec.scrollTarget=0,0
    end

    self:_out(clipL,clipT,clipR-clipL,clipB-clipT,rr,.82,self:_color("outline"),112)

    local titleY=box.y+7*s
    if titleY>=bodyTop-20*s and titleY<=bodyBottom then
        textC(fit(upper(sec.name),max(20,box.w-44*s),14*s,"Verdana"),box.x+22*s,titleY,self:_color("muted"),14*s,"Verdana")
    end
end
-- numeric build identity intentionally omitted
-- numeric build identity intentionally omitted
Fawn.Runtime=Fawn.Runtime or{}
Fawn.Runtime.SectionControlHotfix="rows always reach _drawControl; rounded visible card slice + final outline"
end


-- Fawn Modern final stability layer.
-- Preserves the complete 9.8-era feature set while fixing storage, profile/settings,
-- stable scrolling/toggle animation, and rounded clipped containers.
do
local Window=assert(Fawn.Classes and Fawn.Classes.Window,"Fawn Window class missing")
local SettingsPage=assert(Fawn.Classes and Fawn.Classes.SettingsPage,"Fawn SettingsPage class missing")
local ROOT="Fawn Modern"
local PATHS={Root=ROOT,Configs=ROOT.."/configs",ProfilePictures=ROOT.."/Profile Pictures",LogoPictures=ROOT.."/logo pictures"}
local IMG_EXT={png=true,jpg=true,jpeg=true}
local CFG_EXT={lua=true,cfg=true,txt=true,json=true}
local managedTextures={}

local function fsFinal()return type(file)=="table"and file or nil end
local function normalizeSandboxFinal(p)
    local s=tostring(p or""):gsub("^%s+",""):gsub("%s+$",""):gsub("\\","/"):gsub('^"',""):gsub('"$',""):gsub("/+","/")
    local l=lower(s);local marker="/serotonin/files/";local at=l:find(marker,1,true)
    if at then s=s:sub(at+#marker)elseif l:sub(1,6)=="files/"then s=s:sub(7)elseif l=="files"then s=""end
    return s:gsub("^/+",""):gsub("/+$","")
end
local function basenameFinal(p)p=normalizeSandboxFinal(p);return p:match("([^/]+)$")or p end
local function extFinal(p)return lower((tostring(p or""):match("%.([^%./\\]+)$")or""))end
local function mkdirFinal(path)
    local f=fsFinal();if not f then return false end
    for _,n in ipairs({"mkdir","Mkdir","MakeDirectory","makeDirectory","CreateDirectory","createDirectory"})do
        if type(f[n])=="function"then local ok,r=pcall(f[n],path);if ok and r~=false then return true end end
    end
    return false
end
local function ensureFinal()
    mkdirFinal(ROOT);mkdirFinal(PATHS.Configs);mkdirFinal(PATHS.ProfilePictures);mkdirFinal(PATHS.LogoPictures)
    return PATHS
end
local function normalizeFinal(raw)
    local out,seen={},{}
    local function add(v)
        local s
        if type(v)=="string"then s=v elseif type(v)=="table"then s=v.name or v.Name or v.path or v.Path or v.file or v.File end
        if not s then return end
        local n=basenameFinal(s);if n~=""and not seen[n]then seen[n]=true;out[#out+1]=n end
    end
    if type(raw)=="table"then for k,v in pairs(raw)do if type(k)=="string"and v==true then add(k)else add(v)end end
    elseif type(raw)=="string"then for s in raw:gmatch("[^\r\n]+")do add(s)end end
    sort(out,function(a,b)return lower(a)<lower(b)end)
    return out
end
local function listFinal(kind)
    ensureFinal();kind=tostring(kind or"Configs")
    if kind=="Profiles"or kind=="Profile"then kind="ProfilePictures"elseif kind=="Logos"or kind=="Logo"then kind="LogoPictures"end
    local path=PATHS[kind]or ROOT;local f=fsFinal();if not f then return{}end
    local raw
    for _,n in ipairs({"listdir","ListDir","ListDirectory","list","List","listFiles","ListFiles","listfiles","GetFiles","getFiles","getfiles"})do
        if type(f[n])=="function"then local ok,r=pcall(f[n],path);if ok and(type(r)=="table"or type(r)=="string")then raw=r;break end end
    end
    local src=normalizeFinal(raw);local out={}
    for _,n in ipairs(src)do local e=extFinal(n);if kind=="Configs"then if CFG_EXT[e]then out[#out+1]=n end elseif kind=="ProfilePictures"or kind=="LogoPictures"then if IMG_EXT[e]then out[#out+1]=n end else out[#out+1]=n end end
    return out
end
local function resolveFinal(kind,name)
    name=normalizeSandboxFinal(name)
    if name==""then return""end
    local base=PATHS[kind]or ROOT;local ln=lower(name);local lr=lower(ROOT)
    if ln==lr or ln:sub(1,#lr+1)==lr.."/"then return name end
    local lb=lower(base);if ln==lb or ln:sub(1,#lb+1)==lb.."/"then return name end
    if name:find("/",1,true)then
        if ln:sub(1,17)=="profile pictures/"or ln:sub(1,14)=="logo pictures/"or ln:sub(1,8)=="configs/"then return ROOT.."/"..name end
        return name
    end
    return base.."/"..name
end
local function configPathFinal(name)
    name=tostring(name or"default.lua"):gsub("\\","/");if name==""then name="default.lua"end
    if not name:find("%.[^/]+$")then name=name..".lua"end
    if name:sub(1,#PATHS.Configs)==PATHS.Configs then return name end
    if name:find("/",1,true)then return name end
    return PATHS.Configs.."/"..name
end
local imageErrors={}
local MAX_IMAGE_BYTES=8*1024*1024
local function imageBytesValid(data)
    if type(data)~="string"or #data<4 then return false,"empty image" end
    if #data>MAX_IMAGE_BYTES then return false,"image is larger than 8 MB" end
    local b1,b2,b3,b4=data:byte(1,4)
    local png=b1==137 and b2==80 and b3==78 and b4==71
    local jpg=b1==255 and b2==216 and b3==255
    if not png and not jpg then return false,"only PNG/JPG images are supported" end
    return true
end
local function loadManaged(path,force)
    path=tostring(path or"")
    if path==""then return nil,"empty path" end
    if not force and managedTextures[path]~=nil then
        local cached=managedTextures[path]
        return cached or nil,cached and nil or(imageErrors[path]or"image load failed")
    end
    managedTextures[path]=nil;imageErrors[path]=nil
    local f=fsFinal();if not f or type(f.read)~="function"then imageErrors[path]="file.read unavailable";return nil,imageErrors[path] end
    local ok,data=pcall(f.read,path)
    if not ok or type(data)~="string"or data==""then imageErrors[path]="could not read "..path;managedTextures[path]=false;return nil,imageErrors[path] end
    local valid,why=imageBytesValid(data);if not valid then imageErrors[path]=why;managedTextures[path]=false;return nil,why end
    local loader=utility and utility.LoadImage
    if type(loader)~="function"then imageErrors[path]="utility.LoadImage unavailable";managedTextures[path]=false;return nil,imageErrors[path] end
    local ok2,id=pcall(loader,data)
    if ok2 and type(id)=="number"and id>0 then managedTextures[path]=id;return id end
    imageErrors[path]=ok2 and"utility.LoadImage returned no texture"or tostring(id)
    managedTextures[path]=false;return nil,imageErrors[path]
end

Fawn.StoragePaths={Root=ROOT,Configs=PATHS.Configs,ProfilePictures=PATHS.ProfilePictures,LogoPictures=PATHS.LogoPictures}
function Fawn:EnsureStorage()return ensureFinal()end
function Fawn:GetStoragePaths()return{Root=ROOT,Configs=PATHS.Configs,ProfilePictures=PATHS.ProfilePictures,LogoPictures=PATHS.LogoPictures}end
function Fawn:GetStorageDisplayPaths()
    local q=self:GetStoragePaths();local f=fsFinal();local root=nil
    if f and type(f.root)=="function"then local ok,r=pcall(f.root);if ok and type(r)=="string"and r~=""then root=r:gsub("\\","/"):gsub("/+$","")end end
    if root then for k,v in pairs(q)do q[k]=root.."/"..v end end
    return q
end
function Fawn:ListStorage(kind)return listFinal(kind)end
function Fawn:ResolveStoragePath(kind,name)return resolveFinal(kind,name)end
function Fawn:ClearImageCache(path)
    if path then path=tostring(path);managedTextures[path]=nil;imageErrors[path]=nil else managedTextures={};imageErrors={} end
    return self
end
function Fawn:GetImageError(path)return imageErrors[tostring(path or"")]end
-- Kept for compatibility, but intentionally does nothing unless force=true.
-- Image decoding is never done automatically at library load because LoadImage allocates native textures.
function Fawn:PreloadStorageImages(force)
    if force~=true then return self end
    ensureFinal()
    local loaded=0
    for _,kind in ipairs({"ProfilePictures","LogoPictures"})do
        for _,name in ipairs(listFinal(kind))do
            if loaded>=16 then return self end
            loadManaged(resolveFinal(kind,name),false);loaded=loaded+1
        end
    end
    return self
end
ensureFinal()

local function applyManagedImage(self,field,pathField,retryField,kind,v,force)
    if type(v)=="number"and v>0 then self[field]=v;self[pathField]=nil;self[retryField]=nil;return true end
    if type(v)~="string"or v==""or v:sub(1,1)=="(" then self[field]=nil;self[pathField]=nil;self[retryField]=nil;return false,"no image selected" end
    local path=resolveFinal(kind,v);self[pathField]=path;self[retryField]=nil
    if force then managedTextures[path]=nil;imageErrors[path]=nil end
    local tex,err=loadManaged(path,force==true);self[field]=tex
    return tex~=nil,err
end
function Window:SetProfileImage(v,force)local ok=applyManagedImage(self,"profileImage","profileImagePath","_profileImageRetry","ProfilePictures",v,force);return self,ok end
function Window:ApplyProfileImage(v)local ok,err=applyManagedImage(self,"profileImage","profileImagePath","_profileImageRetry","ProfilePictures",v,true);return ok,err end
function Window:ClearProfileImage()self.profileImage=nil;self.profileImagePath=nil;self._profileImageRetry=nil;return self end
function Window:SetLogoImage(v,force)local ok=applyManagedImage(self,"logoImage","logoImagePath","_logoImageRetry","LogoPictures",v,force);return self,ok end
function Window:ApplyLogoImage(v)local ok,err=applyManagedImage(self,"logoImage","logoImagePath","_logoImageRetry","LogoPictures",v,true);return ok,err end
function Window:ClearLogoImage()self.logoImage=nil;self.logoImagePath=nil;self._logoImageRetry=nil;return self end

-- No per-frame image decoding. Failed assets stay failed until Apply/Refresh is requested.


-- The profile popup is fully authorable but has no build/version action.
local setProfileFinal=Window.SetProfileMenu
function Window:SetProfileMenu(items,opt)
    local out={}
    for _,v in ipairs(type(items)=="table"and items or{})do
        local isBuild=v=="build"or(type(v)=="table"and v.builtin=="build")
        if not isBuild then out[#out+1]=v end
    end
    return setProfileFinal(self,out,opt)
end
local addBuiltinFinal=Window.AddProfileMenuBuiltin
function Window:AddProfileMenuBuiltin(id,opt)if lower(tostring(id or""))=="build"then return nil end return addBuiltinFinal(self,id,opt)end

-- Stable control identity keeps toggle interpolation from restarting every frame while a Section scrolls.
local drawControlFinal=Window._drawControl
function Window:_drawControl(c,r,clipTop,clipBottom)
    local prev=self._activeControlAnimId
    self._activeControlAnimId=c and c.id or prev
    local a,b,d,e=drawControlFinal(self,c,r,clipTop,clipBottom)
    self._activeControlAnimId=prev
    return a,b,d,e
end

-- Rounded fixed/fill Sections: only vertically complete rows render when the row crosses
-- a viewport edge. The old x-bound gate is intentionally gone because it rejected valid rows
-- beside the reserved scrollbar gutter. The visible card slice itself is always rounded.
function Window:_drawSection(box,bodyTop,bodyBottom,bodyLeft,bodyRight)
    local sec=box.section;local s=self.scale;local cardTop=box.cardY;local cardBottom=cardTop+box.cardH
    local clipL=max(bodyLeft or box.x,box.x);local clipR=min(bodyRight or(box.x+box.w),box.x+box.w);local clipT=max(bodyTop,cardTop);local clipB=min(bodyBottom,cardBottom)
    if clipB<=clipT or clipR<=clipL then return end
    if sec._scrollDrag then
        if Input.left and sec.maxScroll>0 then local rr=snapRatio96((Input.my-sec._scrollDrag.top-sec._scrollDrag.off)/max(1,sec._scrollDrag.span));sec.scrollTarget=rr*sec.maxScroll;sec.scroll=sec.scrollTarget
        else sec._scrollDrag=nil;sec.scroll,sec.scrollTarget=settle96(sec.scroll,sec.scrollTarget,sec.maxScroll,self.scrollSpeed,s,false)end
    else sec.scroll,sec.scrollTarget=settle96(sec.scroll,sec.scrollTarget,sec.maxScroll,self.scrollSpeed,s,false)end
    local offset=sec.scroll or 0;offset=round(offset)
    local rr=min(14*s,(clipB-clipT)*.5,(clipR-clipL)*.5)
    self:_fill("card",clipL,clipT,clipR-clipL,clipB-clipT,"card",rr)
    local eps=max(.65,s*.55);local layouts=box.layouts or{}
    for _,c in ipairs(sec.controls or{})do
        local q=layouts[c]
        if q then local r={x=q.x,y=round(q.y-offset),w=q.w,h=q.h};if r.y>=clipT-eps and r.y+r.h<=clipB+eps then self:_drawControl(c,r,clipT,clipB)end end
    end
    if sec.columnDividers==true and sec.columns and sec.columns>1 then
        local gap=(sec.controlGap or 12)*s;local usable=box.w-(((sec.sizeMode=="fixed"or sec.sizeMode=="fill"or sec.maxHeight)and REF.SectionScrollbarGutter or 0)*s);local cw=(usable-gap*(sec.columns-1))/sec.columns
        for i=1,sec.columns-1 do local x=box.x+i*cw+(i-.5)*gap;local y1=max(clipT+rr,cardTop+rr);local y2=min(clipB-rr,cardBottom-rr);if y2>y1 then line(x,y1,x,y2,self:_color("line"),1,14)end end
    end
    if sec.maxScroll>1 then
        local gutter=REF.SectionScrollbarGutter*s;local gx=box.x+box.w-gutter;local tx=gx+gutter*.5;local top=clipT+max(9*s,rr*.72);local bh=max(1,clipB-top-max(9*s,rr*.72));local thumb=max(28*s,bh*(box.cardH/max(box.cardH,box.contentH)));local span=max(1,bh-thumb);local ratio=sec.maxScroll>0 and snapRatio96((sec.scroll or 0)/sec.maxScroll)or 0;local ty=top+span*ratio;local thumbHover=self:_hit(gx,ty-3*s,gutter,thumb+6*s);local trackHover=self:_hit(gx,clipT,gutter,clipB-clipT);local active=sec._scrollDrag~=nil
        if trackHover or active then rect(tx-1*s,top,2*s,bh,self:_color("controlHover"),1*s,88)end
        rect(tx-((active or thumbHover)and 2*s or 1.5*s),ty,(active or thumbHover)and 4*s or 3*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 180)
        if Input.click and not self._consumed and not self:_hasPopup()and thumbHover then sec._scrollDrag={top=top,span=span,off=Input.my-ty};self:_consume()end
    else sec._scrollDrag=nil;sec.scroll,sec.scrollTarget=0,0 end
    self:_out(clipL,clipT,clipR-clipL,clipB-clipT,rr,.82,self:_color("outline"),112)
    local titleY=box.y+7*s;if titleY>=bodyTop-20*s and titleY<=bodyBottom then textC(fit(upper(sec.name),max(20,box.w-44*s),14*s,"Verdana"),box.x+22*s,titleY,self:_color("muted"),14*s,"Verdana")end
end

-- Complete built-in Settings page. It is reusable on any Window/Panel and can be hidden
-- from the sidebar while remaining reachable from the profile popup.
function Fawn:CreateSettingsPage(window,opt)
    if window==self then window,opt=opt,nil end
    if kind(window)~="Window"and kind(window)~="Panel"then error("CreateSettingsPage requires a Fawn Window")end
    if window.settingsPage then return window.settingsPage end
    ensureFinal();self:PreloadStorageImages(false);opt=type(opt)=="table"and opt or{}
    local page=setmetatable({Window=window,Controls={},ConfigPath=configPathFinal(opt.configPath or"default.lua"),Defaults=nil},SettingsPage)
    local tab=window:Tab(opt.title or"Settings",{group=opt.group or"MISCELLANEOUS",icon="settings"});page.Tab=tab;tab.sidebarHidden=opt.showInSidebar==false or opt.profileOnly==true
    local appearance=tab:Section("APPEARANCE",{column=1,row=1,sizeMode="auto"})
    local behavior=tab:Section("BEHAVIOR",{column=2,row=1,sizeMode="auto"})
    local profile=tab:Section("PROFILE & BRAND",{column=1,row=2,sizeMode="auto"})
    local config=tab:Section("CONFIGURATION",{column=2,row=2,sizeMode="auto"})
    local diagnostics=tab:Section("DIAGNOSTICS",{column=1,row=3,span=2,columns=2,sizeMode="auto"})
    local ti=indexOf(Fawn.ThemeNames,window:GetThemeName())or 1
    page.Controls.Theme=appearance:Dropdown("Theme",Fawn.ThemeNames,ti,{noConfig=true});page.Controls.Theme:OnChanged(function(v)window:SetTheme(v);if page._syncColors then page:_syncColors()end end)
    page.Controls.Scale=appearance:Slider("UI Scale",55,165,round(window:GetScale()*100),{noConfig=true,format=function(v)return round(v).."%"end});page.Controls.Scale:OnChanged(function(v)window:SetScale(v/100)end)
    appearance:AddSeparator("MATERIAL")
    local mats=Fawn.SurfaceStyles or{"Solid","Frosted","Acrylic","Smoke","Clear"};page.Controls.SurfaceStyle=appearance:Dropdown("Surface Material",mats,indexOf(mats,window.GetSurfaceStyle and window:GetSurfaceStyle()or"Solid")or 1,{noConfig=true});page.Controls.SurfaceStyle:OnChanged(function(v)if window.SetSurfaceStyle then window:SetSurfaceStyle(v)end;if page.Controls.Glass then page.Controls.Glass:Set(window:GetLiquidGlass(),true)end end)
    page.Controls.Glass=appearance:Toggle("Liquid Glass",window:GetLiquidGlass(),{noConfig=true});page.Controls.Glass:OnChanged(function(v)window:SetLiquidGlass(v);if page.Controls.SurfaceStyle and window.GetSurfaceStyle then page.Controls.SurfaceStyle:Set(window:GetSurfaceStyle(),true)end end)
    page.Controls.GlassOpacity=appearance:Slider("Glass Opacity",18,100,round(window:GetGlassOpacity()*100),{noConfig=true,format=function(v)return round(v).."%"end});page.Controls.GlassOpacity:OnChanged(function(v)window:SetGlassOpacity(v/100)end)
    if window.GetGlassTint then page.Controls.GlassTint=appearance:ColorPicker("Glass Tint",window:GetGlassTint(),{noConfig=true});page.Controls.GlassTint:OnChanged(function(v)window:SetGlassTint(v)end)end
    if window.GetGlassTintStrength then page.Controls.GlassTintStrength=appearance:Slider("Tint Strength",0,65,round(window:GetGlassTintStrength()*100),{noConfig=true,format=function(v)return round(v).."%"end});page.Controls.GlassTintStrength:OnChanged(function(v)window:SetGlassTintStrength(v/100)end)end
    if window.SetSurfaceHighlights then page.Controls.SurfaceHighlights=appearance:Toggle("Glass Highlights",window.surfaceHighlights~=false,{noConfig=true});page.Controls.SurfaceHighlights:OnChanged(function(v)window:SetSurfaceHighlights(v)end)end
    appearance:AddSeparator("GEOMETRY & OUTLINE")
    local corners=Fawn.CornerPresets or{"Square","Tight","Soft","Round"};page.Controls.CornerPreset=appearance:Dropdown("Corner Preset",corners,indexOf(corners,"Round")or 1,{noConfig=true});page.Controls.CornerPreset:OnChanged(function(v)if window.SetCornerPreset then window:SetCornerPreset(v)end end)
    if window.SetRadiusScale then page.Controls.RadiusScale=appearance:Slider("Radius Scale",45,165,round((window.radiusScale or 1)*100),{noConfig=true,format=function(v)return round(v).."%"end});page.Controls.RadiusScale:OnChanged(function(v)window:SetRadiusScale(v/100)end)end
    page.Controls.Outline=appearance:ColorPicker("Outline",window:GetOutlineColor(),{noConfig=true});page.Controls.Outline:OnChanged(function(v)window:SetOutlineColor(v);window:SetThemeColor("outline",v,true)end)
    page.Controls.OutlineStrength=appearance:Slider("Outline Thickness",25,300,round(window:GetOutlineStrength()*100),{noConfig=true,format=function(v)return format("%.2fx",v/100)end});page.Controls.OutlineStrength:OnChanged(function(v)window:SetOutlineStrength(v/100)end)
    if window.SetOutlineOpacity then page.Controls.OutlineOpacity=appearance:Slider("Outline Opacity",15,100,round((window.outlineOpacity or 1)*100),{noConfig=true,format=function(v)return round(v).."%"end});page.Controls.OutlineOpacity:OnChanged(function(v)window:SetOutlineOpacity(v/100)end)end
    appearance:AddSeparator("COLORS")
    local colorDefs={{"Accent","accent"},{"Main Background","menuBg"},{"Card Background","card"},{"Control Background","control"},{"Control Hover","controlHover"},{"Active Item","activeItem"},{"Text","text"},{"Muted Text","muted"},{"Navigation Text","navText"},{"Popup","popup"},{"Icon","icon"},{"Chevron","chev"},{"Toggle Track","toggleTrack"},{"Toggle Knob","toggleKnob"},{"Logo Background","logoBg"},{"Logo Foreground","logoFg"},{"Avatar","avatar"},{"Avatar Dark","avatarDark"},{"Separator Line","line"}}
    page.ColorControls={}
    for _,d in ipairs(colorDefs)do local cp=appearance:ColorPicker(d[1],window:_color(d[2]),{noConfig=true});cp:OnChanged(function(v)window:SetThemeColor(d[2],v,true)end);page.ColorControls[d[2]]=cp end
    function page:_syncColors()for k,c in pairs(self.ColorControls or{})do c:Set(window:_color(k),true)end;if self.Controls.Outline then self.Controls.Outline:Set(window:GetOutlineColor(),true)end end
    appearance:AddButton("Reset Appearance",function()window:SetTheme("Modern Blue"):SetScale(1):SetLiquidGlass(false):SetOutlineStrength(1);if window.ResetPolish then window:ResetPolish()end;page:_syncColors()end)

    page.Controls.Smooth=behavior:Toggle("Smooth Scrolling",window.smoothScroll,{noConfig=true});page.Controls.Smooth:OnChanged(function(v)window:SetSmoothScroll(v)end)
    page.Controls.Anim=behavior:Toggle("Animations",window.animations,{noConfig=true});page.Controls.Anim:OnChanged(function(v)window:SetAnimations(v)end)
    if window.SetMotionStyle then local motions=Fawn.MotionStyles or{"Off","Minimal","Smooth","Snappy","Fluid"};page.Controls.MotionStyle=behavior:Dropdown("Animation Style",motions,indexOf(motions,window.motionStyle or"Smooth")or 1,{noConfig=true});page.Controls.MotionStyle:OnChanged(function(v)window:SetMotionStyle(v)end)end
    page.Controls.MotionSpeed=behavior:Slider("Animation Speed",4,30,round(window.animationSpeed or 10),{noConfig=true});page.Controls.MotionSpeed:OnChanged(function(v)window:SetAnimationSpeed(v)end)
    if window.SetHoverAnimations then page.Controls.HoverAnimations=behavior:Toggle("Animated Hovers",window.hoverAnimations~=false,{noConfig=true});page.Controls.HoverAnimations:OnChanged(function(v)window:SetHoverAnimations(v)end)end
    if window.SetSwitchAnimations then page.Controls.SwitchAnimations=behavior:Toggle("Animated Switches",window.switchAnimations~=false,{noConfig=true});page.Controls.SwitchAnimations:OnChanged(function(v)window:SetSwitchAnimations(v)end)end
    page.Controls.ScrollSpeed=behavior:Slider("Scroll Speed",1,30,window:GetScrollSpeed(),{noConfig=true});page.Controls.ScrollSpeed:OnChanged(function(v)window:SetScrollSpeed(v)end)
    local np=indexOf(Fawn.NotificationPositions,window:GetNotificationPosition())or 4;page.Controls.Notifications=behavior:Dropdown("Notification Corner",Fawn.NotificationPositions,np,{noConfig=true});page.Controls.Notifications:OnChanged(function(v)window:SetNotificationPosition(v)end)
    page.Controls.MenuKey=behavior:Keybind("Menu Key",window.toggleKey,{label=window.toggleLabel,mode="Toggle",keyboardOnly=true,keybindList=false,noConfig=true});page.Controls.MenuKey:OnKeyChanged(function(k,l)window:SetToggleKey(k,l)end)
    behavior:AddButtonPair("Center UI",function()window:Center()end,"Default Size",function()window:SetSize(REF.Width,REF.Height)end)

    page.Controls.ProfileName=profile:Input("Username",window.profileName,{placeholder="User",noConfig=true});page.Controls.ProfileName:OnChanged(function(v)window:SetProfileName(v)end)
    page.Controls.ProfileSub=profile:Input("Subtitle",window.profileSubtitle,{placeholder="Developer",noConfig=true});page.Controls.ProfileSub:OnChanged(function(v)window:SetProfileSubtitle(v)end)
    profile:AddSeparator("PROFILE PICTURE")
    local function imageOpts(kind,empty)local q=listFinal(kind);if #q==0 then return{empty}end return q end
    page.Controls.ProfileBrowser=profile:Dropdown("Profile Picture",imageOpts("ProfilePictures","(no profile pictures)"),1,{noConfig=true})
    profile:AddButtonPair("Apply Picture",function()local v=page.Controls.ProfileBrowser:Get();local ok,err=window:ApplyProfileImage(v);window:Notify(ok and("Applied "..tostring(v))or("Picture failed: "..tostring(err or"unknown error")),{title="PROFILE PICTURE",duration=4})end,"Clear Avatar",function()window:ClearProfileImage()end)
    profile:AddButton("Refresh Pictures",function()page:RefreshBrowsers()end)
    profile:AddSeparator("BRAND & LOGO")
    page.Controls.Brand=profile:Input("Brand Title",window.brand,{noConfig=true});page.Controls.Brand:OnChanged(function(v)window.brand=v end)
    page.Controls.Subtitle=profile:Input("Brand Subtitle",window.subtitle,{noConfig=true});page.Controls.Subtitle:OnChanged(function(v)window.subtitle=v end)
    page.Controls.LogoBrowser=profile:Dropdown("Logo Picture",imageOpts("LogoPictures","(no logo pictures)"),1,{noConfig=true})
    profile:AddButtonPair("Apply Logo",function()local v=page.Controls.LogoBrowser:Get();local ok,err=window:ApplyLogoImage(v);window:Notify(ok and("Applied "..tostring(v))or("Logo failed: "..tostring(err or"unknown error")),{title="LOGO",duration=4})end,"Clear Logo",function()window:ClearLogoImage()end)
    profile:AddButton("Refresh Logos",function()page:RefreshBrowsers()end)

    local cfgs=listFinal("Configs");if #cfgs==0 then cfgs={"(no config files)"}end
    page.Controls.ConfigBrowser=config:Dropdown("Config File",cfgs,1,{noConfig=true});page.Controls.ConfigBrowser:OnChanged(function(v)if v and v:sub(1,1)~="("then page:SetConfigPath(v)end end)
    page.Controls.ConfigName=config:Input("New Config Name","default.lua",{placeholder="default.lua",noConfig=true,maxLength=96})
    config:AddButtonPair("Save As",function()page:SetConfigPath(page.Controls.ConfigName:Get());page:SaveConfig();page:RefreshBrowsers()end,"Load Selected",function()local v=page.Controls.ConfigBrowser:Get();if v and v:sub(1,1)~="("then page:SetConfigPath(v);page:LoadConfig()end end)
    config:AddButtonPair("Refresh Files",function()page:RefreshBrowsers()end,"Show Path",function()page:ShowConfigPath()end)
    config:AddSeparator("IN-MEMORY PROFILES")
    config:AddButtonPair("Save Current",function()window:SaveNamedConfig(window.configName);window:Notify("Named config saved",{title="CONFIG"})end,"Duplicate",function()local n=window:DuplicateNamedConfig();window:Notify("Created "..n,{title="CONFIG"})end)
    config:AddValue("Configs Folder",PATHS.Configs,{muted=true,wrap=true,maxLines=2})

    diagnostics:AddValue("Paint Frames",function()return Fawn:GetPaintCount()end,{controlColumn=1});diagnostics:AddValue("Paint Errors",function()return Fawn:GetPaintErrors()end,{controlColumn=1})
    diagnostics:AddValue("Draw Errors",function()return E.drawErrors end,{controlColumn=2});diagnostics:AddValue("Window Size",function()local w,h=window:GetSize();return round(w).." x "..round(h)end,{controlColumn=2});diagnostics:AddValue("Scale",function()return round(window:GetScale()*100).."%"end,{controlColumn=2})
    diagnostics:AddButton("Test Notification",function()window:Notify("Fawn Modern settings and secondary UI test.",{title="DIAGNOSTICS"})end,{controlColumn=2})

    function page:RefreshBrowsers()
        local function apply(ctrl,list,empty)local q=list;if #q==0 then q={empty}end;if ctrl then ctrl:SetOptions(q,{preserve="text"})end end
        apply(self.Controls.ConfigBrowser,listFinal("Configs"),"(no config files)")
        apply(self.Controls.ProfileBrowser,listFinal("ProfilePictures"),"(no profile pictures)")
        apply(self.Controls.LogoBrowser,listFinal("LogoPictures"),"(no logo pictures)")
        return self
    end
    page:CaptureDefaults();window.settingsPage=page;page:RefreshBrowsers();return page
end

function Fawn:CreatePresetSettingsMenu(window,opt)
    if window==self then window,opt=opt,nil end
    opt=type(opt)=="table"and copy(opt)or{};opt.showInSidebar=opt.showInSidebar==true;opt.profileOnly=opt.showInSidebar~=true;opt.title=opt.title or"Settings";opt.group=opt.group or"MISCELLANEOUS";opt.configPath=opt.configPath or"default.lua"
    local page=self:CreateSettingsPage(window,opt);if page and page.Tab and opt.showInSidebar~=true then page.Tab.sidebarHidden=true end
    if opt.profileEntry~=false and window then local item={builtin="settings",label=opt.profileLabel or"Settings",icon=opt.profileIcon or"settings"};if opt.profileMenuOnly==true then window:SetProfileMenu({item},{title=opt.profileMenuTitle or"PROFILE",width=opt.profileMenuWidth or 261})else window:AddProfileMenuBuiltin("settings",item)end end
    if window then window.presetSettingsPage=page end
    return page
end
function Window:AddPresetSettingsMenu(opt)return Fawn:CreatePresetSettingsMenu(self,opt)end
Window.CreatePresetSettingsMenu=Window.AddPresetSettingsMenu
function Window:GetPresetSettingsMenu()return self.presetSettingsPage or self.settingsPage end
function Window:OpenPresetSettings()local p=self:GetPresetSettingsMenu()or self:AddPresetSettingsMenu({profileEntry=false});if p and p.Tab then self:SelectTab(p.Tab)end;self.accountOpen=false;return p end
function Window:AttachSettingsToProfile(opt)
    opt=type(opt)=="table"and opt or{};local p=self:GetPresetSettingsMenu()or self:AddPresetSettingsMenu({profileEntry=false,configPath=opt.configPath})
    local item={builtin="settings",label=opt.label or"Settings",icon=opt.icon or"settings"};if opt.only~=false then self:SetProfileMenu({item},{title=opt.title or"PROFILE",width=opt.width or 261})else self:AddProfileMenuBuiltin("settings",item)end
    return p
end

-- New windows no longer expose a build/version row by default. Scripts can still fully author this menu.
local createWindowFinal=Fawn.CreateWindow
function Fawn:CreateWindow(opt)
    local w=createWindowFinal(self,opt)
    if w and w.profileMenuExact==nil then w:SetProfileMenu({"settings","profile","center","close"},{title="PROFILE"})end
    return w
end

-- No numeric build/version system is exposed.
Fawn.DisplayName="Fawn Modern";Fawn.ProductName="Fawn Modern";Fawn.Namespace="FawnModern"
function Fawn:AssertCompatible()return true end
Fawn.DynamicCapabilities=Fawn.DynamicCapabilities or{}
Fawn.DynamicCapabilities.ManagedStorage=true;Fawn.DynamicCapabilities.PresetSettingsMenu=true;Fawn.DynamicCapabilities.ProfileMenuAuthoring=true;Fawn.DynamicCapabilities.StableSectionClipping=true;Fawn.DynamicCapabilities.StableToggleAnimation=true
Fawn.Runtime=Fawn.Runtime or{}
Fawn.Runtime.StorageRoot=ROOT;Fawn.Runtime.StoragePaths=Fawn:GetStoragePaths();Fawn.Runtime.PresetSettings="profile-popup or sidebar-mounted reusable Settings";Fawn.Runtime.SectionScrolling="pixel-snapped vertical full-row clipping + rounded visible slice";Fawn.Runtime.ToggleAnimation="stable control identity while scrolling"
end


-- Final interaction / secondary-window / managed-image hotfix.
do
local Window=assert(Fawn.Classes and Fawn.Classes.Window,"Fawn Window class missing")

-- Small Neverlose-style windows keep authored sections inside the shell. Narrow content
-- automatically reflows instead of allowing columns to overlap each other.
local buildResponsiveBase=Window._buildLayout
function Window:_buildLayout(tab)
    local authored=max(1,floor(tonumber(self.columns)or 1))
    local panel=self.kind=="Panel"or self.tabBarVisible==false
    local logical=max(1,panel and(self.width-36)or(self.width-REF.ContentX-REF.RightMargin))
    local minColumn=285
    local responsive=clamp(floor((logical+REF.ColumnGap)/(minColumn+REF.ColumnGap)),1,authored)
    if responsive>=authored or not tab then return buildResponsiveBase(self,tab)end

    local items={}
    for i,sec in ipairs(tab.sections or{})do
        if alive(sec)and visibilityPass(sec)then items[#items+1]={sec=sec,i=i,row=sec.row or 1,col=sec.column or 1,span=sec.span or 1}end
    end
    sort(items,function(a,b)if a.row==b.row then if a.col==b.col then return a.i<b.i end return a.col<b.col end return a.row<b.row end)

    local saved={};local row,col=1,1
    for _,q in ipairs(items)do
        local sec=q.sec;saved[#saved+1]={sec=sec,row=sec.row,column=sec.column,span=sec.span}
        local full=(tonumber(q.span)or 1)>=authored
        if full then
            if col~=1 then row=row+1;col=1 end
            sec.row,sec.column,sec.span=row,1,responsive;row=row+1
        else
            sec.row,sec.column,sec.span=row,col,1
            col=col+1;if col>responsive then col=1;row=row+1 end
        end
    end

    local oldColumns=self.columns;self.columns=responsive
    local ok,result=pcall(buildResponsiveBase,self,tab)
    self.columns=oldColumns
    for _,q in ipairs(saved)do q.sec.row,q.sec.column,q.sec.span=q.row,q.column,q.span end
    if not ok then error(result)end
    if type(result)=="table"then result.responsiveColumns=responsive end
    return result
end

-- The former fixed 250px config control could extend past a secondary window. This version
-- progressively compacts Save / Config / Group / Search without drawing outside the content inset.
function Window:_drawTopbar()
    local s=self.scale;local X,Y=self.x,self.y
    local left=X+REF.ContentX*s;local right=X+(self.width-REF.RightMargin)*s
    local top=Y+20*s;local h=50*s;local avail=max(0,right-left)
    if avail<60*s then return end
    local gap=7*s

    local function saveBox(x,w)
        local hov=self:_hit(x,top,w,h)and not self:_hasPopup()
        self:_fill("control",x,top,w,h,hov and"controlHover"or"card",12*s);self:_out(x,top,w,h,12*s,.8,self:_color("outline"),105)
        self:_icon("save",x+w*.5,top+h*.5,min(21*s,w*.46),"text")
        if Input.click and not self._consumed and not self:_hasPopup()and hov then self:SaveNamedConfig(self.configName);self:Notify("Saved "..self.configName,{title="CONFIG"});self:_consume()end
    end
    local function configBox(x,w)
        if w<=0 then return end
        local hov=self:_hit(x,top,w,h)and not(self.openDrop or self.keyMenu or self.colorPopup or self.groupPopup or self.accountOpen)
        self:_fill("control",x,top,w,h,hov and"controlHover"or"card",12*s);self:_out(x,top,w,h,12*s,.8,self:_color("outline"),105)
        local fs=max(12*s,min(17*s,w*.12))
        textC(fit(self.configName,max(8,w-34*s),fs,"Verdana"),x+12*s,top+25*s,self:_color("text"),fs,"Verdana")
        if w>=48*s then chevDown(x+w-17*s,top+25*s,min(14*s,w*.16),self:_color("chev"),self.configPopup~=nil)end
        if Input.click and not self._consumed and hov then self.configPopup=self.configPopup and nil or{x=x,y=top+h+6*s,w=max(100*s,w)};self.openDrop=nil;self.keyMenu=nil;self.colorPopup=nil;self.groupPopup=nil;self.accountOpen=false;self:_consume()end
    end
    local function groupBox(x,w)
        if w<=0 then return end
        local hov=self:_hit(x,top,w,h)and not(self.openDrop or self.keyMenu or self.colorPopup or self.configPopup or self.accountOpen)
        self:_fill("control",x,top,w,h,hov and"controlHover"or"card",12*s);self:_out(x,top,w,h,12*s,.8,self:_color("outline"),105)
        local fs=max(11*s,min(16*s,w*.13))
        textC(fit(self.group,max(8,w-30*s),fs,"Verdana"),x+10*s,top+25*s,self:_color("text"),fs,"Verdana")
        if w>=44*s then chevDown(x+w-15*s,top+25*s,min(13*s,w*.16),self:_color("chev"),self.groupPopup~=nil)end
        if Input.click and not self._consumed and hov then
            if type(self.groupClick)=="function"then pcall(self.groupClick,self)else self.groupPopup=self.groupPopup and nil or{x=x,y=top+h+6*s,w=max(96*s,w)}end
            self.openDrop=nil;self.keyMenu=nil;self.colorPopup=nil;self.configPopup=nil;self.accountOpen=false;self:_consume()
        end
    end
    local function searchBox(x,w)
        local hov=self:_hit(x,top,w,h)and not self:_hasPopup()
        if hov then self:_fill("control",x,top,w,h,"activeItem",12*s)end
        self:_icon("search",x+w*.5,top+h*.5,min(20*s,w*.45),hov and"text"or"icon")
        if Input.click and not self._consumed and not self:_hasPopup()and hov then self.searchOpen=not self.searchOpen;self:_consume()end
    end

    if avail>=470*s then
        local saveW=50*s;local searchW=44*s;local groupW=142*s
        local configX=left+saveW+gap
        local configW=min(245*s,max(100*s,avail-saveW-searchW-groupW-gap*3-11*s))
        local groupX=configX+configW+18*s;local searchX=right-searchW
        if groupX+groupW>searchX-10*s then groupW=max(72*s,searchX-10*s-groupX)end
        saveBox(left,saveW);configBox(configX,configW);groupBox(groupX,groupW);searchBox(searchX,searchW)
    elseif avail>=205*s then
        local saveW=40*s;local rest=avail-saveW-gap*2
        local groupW=clamp(rest*.42,64*s,110*s);local configW=max(64*s,rest-groupW)
        if configW+groupW>rest then groupW=max(58*s,rest-configW)end
        local configX=left+saveW+gap;local groupX=configX+configW+gap
        saveBox(left,saveW);configBox(configX,configW);groupBox(groupX,max(0,right-groupX))
    elseif avail>=126*s then
        local each=(avail-gap)*.5;configBox(left,each);groupBox(left+each+gap,max(0,right-(left+each+gap)))
    else
        configBox(left,avail)
    end
end

function Window:_drawPanelHeader()
    local s=self.scale;local X,Y=self.x,self.y;local W=self.width*s
    self:_fill("sidebar",X,Y,W,64*s,"card",self.corner*s)
    line(X+12*s,Y+64*s,X+W-12*s,Y+64*s,self:_color("line"),1,36)
    local toggle=tostring(self.toggleLabel or"");local tw=measure(toggle,12*s,"Verdana")
    local textRight=X+W-18*s-(toggle~=""and(tw+16*s)or 0)
    local maxText=max(28*s,textRight-(X+18*s))
    textC(fit(self.brand,maxText,18*s,"Verdana"),X+18*s,Y+25*s,self:_color("text"),18*s,"Verdana")
    if self.subtitle~=""then textC(fit(self.subtitle,maxText,12*s,"Verdana"),X+18*s,Y+45*s,self:_color("muted"),12*s,"Verdana")end
    if toggle~=""then textC(toggle,X+W-18*s-tw,Y+32*s,self:_color("muted"),12*s,"Verdana")end
end

-- Timed recovery handles assets added after the window was created without decoding every frame.
local function retryWindowAsset(w,which)
    local field=which=="logo"and"logoImage"or"profileImage"
    local pathField=which=="logo"and"logoImagePath"or"profileImagePath"
    if w[field]or not w[pathField]or w[pathField]==""then return end
    local n=nowMs();local key=which=="logo"and"_nextLogoRetryFix"or"_nextProfileRetryFix"
    if n<(w[key]or 0)then return end;w[key]=n+(Fawn.Performance.ImageRetryMs or 5000)
    if which=="logo"then w:SetLogoImage(w[pathField],true)else w:SetProfileImage(w[pathField],true)end
end

-- A custom transparent logo replaces the fallback tile instead of sitting on a white square.
function Window:_drawLogo()
    retryWindowAsset(self,"logo")
    local s=self.scale;local X,Y=self.x,self.y;local lx,ly=X+25*s,Y+20*s
    if self.logoImage then
        drawImage(self.logoImage,lx,ly,50*s,50*s,1)
    else
        self:_fill("control",lx,ly,50*s,50*s,"logoBg",12*s,255)
        local lw,lh=measure(self.logo,24*s,"Verdana");text(self.logo,lx+25*s-lw*.5,ly+25*s-lh*.5,self:_color("logoFg"),24*s,"Verdana")
    end
    local tx=X+98*s;local maxW=max(38*s,(REF.Sidebar-118)*s)
    textC(fit(self.brand,maxW,22*s,"Verdana"),tx,Y+33*s,self:_color("white"),22*s,"Verdana")
    local lines=wrapText(self.subtitle,maxW,11*s,"Verdana",2);if #lines==0 then lines={""}end
    local baseY=Y+50*s;local step=12*s
    for i,v in ipairs(lines)do textC(v,tx,baseY+(i-1)*step,self:_color("muted"),11*s,"Verdana")end
end

local sidebarAssetBase=Window._drawSidebar
function Window:_drawSidebar()
    retryWindowAsset(self,"profile")
    return sidebarAssetBase(self)
end


-- Original-Fawn background effects. These flags used to only store booleans in Modern;
-- now they actually render. "Background Blur" matches the original Fawn behavior: a
-- soft full-screen dim/frost layer behind the UI. Snow is lightweight and initialized lazily.
function Window:SetBackgroundBlur(v)self.backgroundBlur=v==true;return self end
function Window:SetBackgroundSnow(v)
    self.backgroundSnow=v==true
    if not self.backgroundSnow then self._snowFix=nil end
    return self
end
function Window:_initBackgroundSnowFix()
    local sw,sh=screenSize();self._snowFix={}
    local count=clamp(floor(tonumber(Fawn.Performance.SnowParticles)or 48),0,120)
    for i=1,count do
        local r=math.random and math.random()or .5
        local r2=math.random and math.random()or .5
        local r3=math.random and math.random()or .5
        local r4=math.random and math.random()or .5
        local r5=math.random and math.random()or .5
        self._snowFix[i]={x=r*sw,y=r2*sh,r=.7+r3*1.4,v=18+r4*34,drift=-7+r5*14,phase=(math.random and math.random()or .5)*6.28318530718}
    end
end
function Window:_drawBackgroundFxFix()
    if self.visible==false or self.destroyed or(not self.backgroundBlur and not self.backgroundSnow)then return end
    if E._backgroundFxPaint==E.paintCount then return end
    E._backgroundFxPaint=E.paintCount
    local sw,sh=screenSize()
    if self.backgroundBlur then rect(0,0,sw,sh,{9,8,12,255},0,105)end
    if self.backgroundSnow then
        if not self._snowFix or #self._snowFix==0 then self:_initBackgroundSnowFix()end
        local d=clamp(dt(),0,.05);local tick=nowMs()*.001;local col=self:_color("white")
        for i=1,#self._snowFix do
            local q=self._snowFix[i]
            q.y=q.y+q.v*d;q.x=q.x+(q.drift+sin(tick+q.phase)*4)*d
            if q.y>sh+6 then q.y=-6;q.x=(math.random and math.random()or .5)*sw end
            if q.x<-6 then q.x=sw+6 elseif q.x>sw+6 then q.x=-6 end
            circle(q.x,q.y,q.r,col,145)
        end
    end
end
local renderBackgroundFxBase=Window._render
function Window:_render()
    self:_drawBackgroundFxFix()
    return renderBackgroundFxBase(self)
end


-- ============================================================================
-- Settings + accessory interaction finishing layer
-- ============================================================================

-- Color chips can be opened from inside the three-dot accessory popup.
-- Normal controls still keep the existing modal guard.
function Window:_drawColorChip(c,right,cy,F,interactive,allowNested)
    local s=self.scale
    local sz=20*s
    local x=right-sz
    local y=cy-sz*.5
    local hov=self:_hit(x-3*s,y-3*s,sz+6*s,sz+6*s)
    local hv=hov and 1 or 0
    local card=self:_color("card")
    local outlineCol=blend(self:_color("outline"),self:_color("accent"),hv*.22)

    rect(x,y,sz,sz,card,5*s,255)
    self:_out(x,y,sz,sz,5*s,1,outlineCol,255)

    local ix,iy,iw,ih=x+2*s,y+2*s,sz-4*s,sz-4*s
    local tile=4*s
    local cols=max(1,ceil(iw/tile))
    local rows=max(1,ceil(ih/tile))
    for yy=0,rows-1 do
        for xx=0,cols-1 do
            local tx=ix+xx*tile
            local ty=iy+yy*tile
            local tw=min(tile,ix+iw-tx)
            local th=min(tile,iy+ih-ty)
            if tw>0 and th>0 then
                local cc=((xx+yy)%2==0)and{72,70,78,255}or{39,38,44,255}
                rect(tx,ty,tw,th,cc,0,255)
            end
        end
    end
    rect(ix,iy,iw,ih,c.value,4*s,c.value[4]or 255)

    local sameColor=self.colorPopup and self.colorPopup.control==c
    local sameMenu=self.colorMenu and self.colorMenu.control==c
    local modalOK=allowNested==true or not self:_hasPopup()or sameColor or sameMenu
    if interactive and not self._consumed and modalOK then
        if Input.click and hov then
            if sameColor then
                self.colorPopup=nil
            else
                self.colorPopup={
                    control=c,
                    x=x,y=y,w=sz,h=sz,
                    drag=nil,
                    triggerX=x,triggerY=y,triggerW=sz,triggerH=sz
                }
                self.colorMenu=nil
            end
            self:_consume()
        elseif Input.rightClick and hov then
            if sameMenu then
                self.colorMenu=nil
            else
                self.colorMenu={
                    control=c,x=Input.mx,y=Input.my,w=168*s,h=94*s,
                    triggerX=x,triggerY=y,triggerW=sz,triggerH=sz
                }
                self.colorPopup=nil
            end
            self:_consume()
        end
    end
    return x,y,sz,sz
end

local function accessoryRowFinal(win,c,x,y,w,h,C,canInteract)
    local s=win.scale
    local left=x+C.padL*s
    local right=x+w-C.padR*s
    local cy=y+h*.5
    local labelW=max(30*s,w*.42)
    local label=fit(c.label or"",labelW,C.font*s,"Verdana")

    if c.type~="button"and c.type~="label"and c.type~="separator"then
        textC(label,left,cy,win:_color("text"),C.font*s,"Verdana")
    end

    if c.type=="toggle"then
        local tw,th=C.togW*s,C.togH*s
        local tx=right-tw
        local ty=cy-th*.5
        local on=c.value==true
        rect(tx,ty,tw,th,on and win:_color("accent")or win:_color("toggleTrack"),th*.5,255)
        local kp=(th-C.knob*s)*.5
        circle(on and(tx+tw-kp-C.knob*s*.5)or(tx+kp+C.knob*s*.5),cy,C.knob*s*.5,win:_color("white"),255)
        if canInteract and Input.click and not win._consumed and win:_hit(tx,ty,tw,th)then
            c:Set(not on)
            win:_consume()
        end

    elseif c.type=="slider"then
        local editing=win.sliderEdit and win.sliderEdit.control==c
        local display=win:_sliderDisplay(c,c.value or c.min)
        local shown=editing and tostring(win.sliderEdit.text or"")or display
        local tw=measure(shown,C.valFont*s,"Verdana")
        local vw=max((editing and 64 or 48)*s,tw+C.valPad*2*s)
        local vx=right-vw
        local vh=C.valH*s
        local vy=cy-vh*.5

        local sx=left+labelW
        local sw=max(28*s,vx-C.sGap*s-sx)
        rect(sx,cy-2*s,sw,4*s,win:_color("control"),2*s,255)

        local range=max(.00001,c.max-c.min)
        local q=clamp((clamp(c.value or c.min,c.min,c.max)-c.min)/range,0,1)
        local kx=sx+q*sw
        rect(sx,cy-2*s,max(0,kx-sx),4*s,win:_color("accent"),2*s,255)
        circle(kx,cy,max(4*s,C.sKnob*s*.32),win:_color("white"),255)

        local vhv=win:_hit(vx,vy,vw,vh)
        win:_fill("control",vx,vy,vw,vh,(editing or vhv)and"controlHover"or"control",C.valR*s)
        if editing then
            win:_out(vx,vy,vw,vh,C.valR*s,1,win:_color("accent"),255)
            local ex=floor(vx+(vw-tw)*.5)
            textC(shown,ex,cy,win:_color("text"),C.valFont*s,"Verdana")
            local cursor=clamp(win.sliderEdit.cursor or#shown,0,#shown)
            local pre=string.sub(shown,1,cursor)
            local preW=caretWidth(pre,C.valFont*s,"Verdana")
            if(nowMs()-(win.sliderEdit.blink or 0))%900<450 then
                local cx=clamp(ex+floor(preW+.5),floor(vx+2*s),floor(vx+vw-2*s))
                caretLine(cx,cy,shown,C.valFont*s,"Verdana",win:_color("text"),255)
            end
        else
            textC(display,vx+(vw-measure(display,C.valFont*s,"Verdana"))*.5,cy,win:_color("text"),C.valFont*s,"Verdana")
        end

        if c._accessoryDrag then
            if Input.left then
                c:Set(c.min+clamp((Input.mx-sx)/max(1,sw),0,1)*(c.max-c.min))
            else
                c._accessoryDrag=nil
            end
        end

        if canInteract and Input.click and not win._consumed then
            if vhv then
                win:_startSliderEdit(c,{vx,vy,vw,vh})
                win:_consume()
            elseif win:_hit(sx,cy-15*s,sw,30*s)then
                c._accessoryDrag=true
                c:Set(c.min+clamp((Input.mx-sx)/max(1,sw),0,1)*(c.max-c.min))
                win:_consume()
            end
        end

    elseif c.type=="dropdown"or c.type=="multiselect"then
        local fw=min(148*s,max(82*s,w*.48))
        local fh=C.ddH*s
        local fx=right-fw
        local fy=cy-fh*.5
        local hov=win:_hit(fx,fy,fw,fh)
        local opened=win.openDrop and win.openDrop.control==c
        win:_fill("control",fx,fy,fw,fh,(hov or opened)and"controlHover"or"control",C.ddR*s)
        local textv=c.type=="multiselect"and c:GetSummary()or tostring(c:Get()or"None")
        textC(fit(textv,fw-34*s,C.ddFont*s,"Verdana"),fx+C.ddPadL*s,cy,win:_color("text"),C.ddFont*s,"Verdana")
        chevDown(fx+fw-C.ddPadR*s-C.chev*s*.5,cy,C.chev*s,win:_color("chev"),opened)
        local ownDrop=win.openDrop and win.openDrop.control==c
        if (canInteract or ownDrop)and Input.click and not win._consumed and hov then
            if ownDrop then win.openDrop=nil else win:_openDropdown(c,fx,fy,fw,fh)end
            win:_consume()
        end

    elseif c.type=="keybind"then
        local shown=win:_keyLabel(c)
        local tw=measure(shown,C.keyFont*s,"Verdana")
        local fw=min(138*s,max(76*s,tw+C.keyPad*2*s))
        local fh=C.keyH*s
        local fx=right-fw
        local fy=cy-fh*.5
        local hov=win:_hit(fx,fy,fw,fh)
        win:_fill("control",fx,fy,fw,fh,hov and"controlHover"or"control",C.keyR*s)
        textC(shown,fx+(fw-tw)*.5,cy,win.captureBind==c and win:_color("accent")or win:_color("text"),C.keyFont*s,"Verdana")
        if canInteract and Input.click and not win._consumed and hov then
            win.captureBind=c
            win._captureFrame=E.paintCount
            win:_consume()
        elseif canInteract and Input.rightClick and not win._consumed and hov then
            win.keyMenu={control=c,x=fx,y=fy+fh+5*s,w=162*s,h=3*C.itemH*s}
            win:_consume()
        end

    elseif c.type=="color"then
        local ownColor=(win.colorPopup and win.colorPopup.control==c)or(win.colorMenu and win.colorMenu.control==c)
        win:_drawColorChip(c,right,cy,C,canInteract or ownColor,true)

    elseif c.type=="input"then
        local fw=min(150*s,max(86*s,w*.48))
        local fh=C.ddH*s
        local fx=right-fw
        local fy=cy-fh*.5
        local hov=win:_hit(fx,fy,fw,fh)
        win:_fill("control",fx,fy,fw,fh,hov and"controlHover"or"control",C.ddR*s)
        local focused=win.inputEdit and win.inputEdit.control==c
        local raw=tostring(c.value or"")
        local shown,caret,start=win:_visibleInputText(c,fw,C)
        local col=win:_color("text")
        if raw==""and not focused then shown=tostring(c.placeholder or"");col=win:_color("muted")end
        local textX=floor(fx+C.ddPadL*s)
        textC(shown,textX,cy,col,C.ddFont*s,"Verdana")
        if focused and(nowMs()-(win.inputEdit.blink or 0))%900<450 then
            local cx=clamp(textX+floor(caret+.5),textX-1,floor(fx+fw-C.ddPadR*s))
            caretLine(cx,cy,shown,C.ddFont*s,"Verdana",win:_color("accent"),255)
        end
        c._inputRect={fx,fy,fw,fh}
        if canInteract and Input.click and not win._consumed and hov then
            if not focused then win:_focusInput(c)end
            local ed=win.inputEdit
            if ed and ed.control==c then
                local rawv=tostring(c.value or"")
                local masked=c.password and string.rep("*",#rawv)or rawv
                local _,_,vstart=win:_visibleInputText(c,fw,C)
                local localX=clamp(Input.mx-textX,0,max(0,fw-(C.ddPadL+C.ddPadR)*s))
                local best=max(0,vstart-1)
                local bestDist=abs(localX)
                for p=max(0,vstart-1),#masked do
                    local ww=measure(sub(masked,vstart,p),renderedFontSize(C.ddFont*s),"Verdana")
                    local d=abs(localX-ww)
                    if d<=bestDist then best,bestDist=p,d else break end
                end
                ed.cursor=clamp(best,0,#rawv)
                ed.blink=nowMs()
            end
            win:_consume()
        end

    elseif c.type=="button"then
        local bx=left
        local bw=right-left
        local bh=max(28*s,h-12*s)
        local by=cy-bh*.5
        local hov=win:_hit(bx,by,bw,bh)
        win:_fill("control",bx,by,bw,bh,hov and"controlHover"or"control",8*s)
        local txt=fit(c.label,bw-18*s,C.font*s,"Verdana")
        local tw=measure(txt,C.font*s,"Verdana")
        textC(txt,bx+(bw-tw)*.5,cy,win:_color("text"),C.font*s,"Verdana")
        if canInteract and Input.click and not win._consumed and hov then
            if type(c.fn)=="function"then pcall(c.fn,c)end
            win:_consume()
        end

    elseif c.type=="label"then
        local lines=wrapText(c.label,max(20,right-left),C.font*s,"Verdana",c.maxLines or 3)
        local lh=17*s
        win:_drawWrapped(lines,left,cy-#lines*lh*.5,win:_color("text"),C.font*s,lh,false)

    elseif c.type=="separator"then
        local t=fit(upper(c.label),max(20,right-left),11*s,"Verdana")
        textC(t,left,cy,win:_color("muted"),11*s,"Verdana")
    end
end

-- Three-dot accessory popup is modal. When one of its child popups is open,
-- the accessory rows become draw-only so a dropdown/color click cannot fall
-- through and activate the row underneath it.
function Window:_drawExtraPopup()
    local p=self.extraPopup
    if not p then return end
    local parent=p.control
    if not alive(parent)then self.extraPopup=nil return end

    local s=self.scale
    local C=REF.Compact
    local k=parent.keybind
    local extras=parent.extraSection and parent.extraSection.controls or{}
    local keyRows=(k and not k.accessoryOnly)and 1 or 0
    local visibleExtras={}
    for _,c in ipairs(extras)do
        if alive(c)and visibilityPass(c)then visibleExtras[#visibleExtras+1]=c end
    end

    local count=keyRows+#visibleExtras
    local header=34*s
    local rowH=C.rowH*s
    p.w=REF.AccessoryWidth*s
    p.h=header+max(1,count)*rowH+8*s
    p.anchorY=p.anchorY or p.y-8*s
    self:_clampPopup(p)
    self:_popupFrame(p)

    textC("OPTIONS",p.x+14*s,p.y+18*s,self:_color("muted"),12*s,"Verdana")

    local nested=self.openDrop or self.colorPopup or self.colorMenu or self.keyMenu
    local canInteract=not nested
    local y=p.y+header

    if k and not k.accessoryOnly then
        local shown=self:_keyLabel(k)
        local tw=measure(shown,C.keyFont*s,"Verdana")
        local fw=min(126*s,max(76*s,tw+C.keyPad*2*s))
        local fh=C.keyH*s
        local fx=p.x+p.w-C.padR*s-fw
        local fy=y+(rowH-fh)*.5
        local cy=y+rowH*.5
        local hov=self:_hit(fx,fy,fw,fh)
        textC("Keybind",p.x+C.padL*s,cy,self:_color("text"),C.font*s,"Verdana")
        self:_fill("control",fx,fy,fw,fh,hov and"controlHover"or"control",C.keyR*s)
        textC(shown,fx+(fw-tw)*.5,cy,self.captureBind==k and self:_color("accent")or self:_color("text"),C.keyFont*s,"Verdana")

        if canInteract and Input.click and not self._consumed and hov then
            self.captureBind=k
            self._captureFrame=E.paintCount
            self.inputEdit=nil
            self:_consume()
        elseif canInteract and Input.rightClick and not self._consumed and hov then
            self.keyMenu={control=k,x=fx,y=fy+fh+5*s,w=162*s,h=3*C.itemH*s}
            self:_consume()
        end
        y=y+rowH
    end

    for _,c in ipairs(visibleExtras)do
        accessoryRowFinal(self,c,p.x,y,p.w,rowH,C,canInteract)
        y=y+rowH
    end

    -- Consume an otherwise-unused click inside the accessory shell itself.
    if canInteract and(Input.click or Input.rightClick)and not self._consumed and self:_hit(p.x,p.y,p.w,p.h)then
        self:_consume()
    end
end

-- A polished built-in settings page. Everything here is live functionality;
-- it is intentionally not a page of decorative/demo-only switches.
function Fawn:CreateSettingsPage(window,opt)
    if window==self then window,opt=opt,nil end
    if kind(window)~="Window"and kind(window)~="Panel"then
        error("CreateSettingsPage requires a Fawn Window")
    end
    if window.settingsPage then return window.settingsPage end

    self:EnsureStorage()
    self:PreloadStorageImages(false)
    opt=type(opt)=="table"and opt or{}

    local SettingsClass=assert(Fawn.Classes and Fawn.Classes.SettingsPage,"Fawn SettingsPage class missing")
    local page=setmetatable({Window=window,Controls={},ConfigPath=tostring(opt.configPath or"default.lua"),Defaults=nil},SettingsClass)
    page:SetConfigPath(opt.configPath or"default.lua")

    local tab=window:Tab(opt.title or"Settings",{group=opt.group or"MISCELLANEOUS",icon="settings"})
    page.Tab=tab
    tab.sidebarHidden=opt.showInSidebar==false or opt.profileOnly==true

    local style=tab:Section("STYLE & MATERIAL",{column=1,row=1,sizeMode="auto"})
    local windowFx=tab:Section("WINDOW & EFFECTS",{column=2,row=1,sizeMode="auto"})
    local behavior=tab:Section("MOTION & INPUT",{column=1,row=2,sizeMode="auto"})
    local profile=tab:Section("PROFILE & BRAND",{column=2,row=2,sizeMode="auto"})
    local colors=tab:Section("THEME COLORS",{column=1,row=3,span=2,columns=2,sizeMode="fixed",height=500})
    local config=tab:Section("CONFIGURATION",{column=1,row=4,sizeMode="auto"})
    local diagnostics=tab:Section("DIAGNOSTICS",{column=2,row=4,sizeMode="auto"})
    local performance=tab:Section("PERFORMANCE",{column=1,row=5,span=2,columns=2,sizeMode="auto"})

    style:AddLabel("Live appearance controls for this window.",{muted=true,wrap=true,maxLines=2})
    local ti=indexOf(Fawn.ThemeNames,window:GetThemeName())or 1
    page.Controls.Theme=style:Dropdown("Theme",Fawn.ThemeNames,ti,{noConfig=true})
    page.Controls.Theme:OnChanged(function(v)
        window:SetTheme(v)
        if page._syncColors then page:_syncColors()end
    end)

    local mats=Fawn.SurfaceStyles or{"Solid","Frosted","Acrylic","Smoke","Clear"}
    page.Controls.SurfaceStyle=style:Dropdown(
        "Surface Material",
        mats,
        indexOf(mats,window.GetSurfaceStyle and window:GetSurfaceStyle()or"Solid")or 1,
        {noConfig=true}
    )
    page.Controls.SurfaceStyle:OnChanged(function(v)
        if window.SetSurfaceStyle then window:SetSurfaceStyle(v)end
        if page.Controls.Glass then page.Controls.Glass:Set(window:GetLiquidGlass(),true)end
    end)

    page.Controls.Glass=style:Toggle("Liquid Glass",window:GetLiquidGlass(),{noConfig=true})
    page.Controls.Glass:OnChanged(function(v)
        window:SetLiquidGlass(v)
        if page.Controls.SurfaceStyle and window.GetSurfaceStyle then
            page.Controls.SurfaceStyle:Set(window:GetSurfaceStyle(),true)
        end
    end)

    page.Controls.GlassOpacity=style:Slider(
        "Glass Opacity",18,100,round(window:GetGlassOpacity()*100),
        {noConfig=true,format=function(v)return round(v).."%"end}
    )
    page.Controls.GlassOpacity:OnChanged(function(v)window:SetGlassOpacity(v/100)end)

    if window.GetGlassTint then
        page.Controls.GlassTint=style:ColorPicker("Glass Tint",window:GetGlassTint(),{noConfig=true})
        page.Controls.GlassTint:OnChanged(function(v)window:SetGlassTint(v)end)
    end
    if window.GetGlassTintStrength then
        page.Controls.GlassTintStrength=style:Slider(
            "Tint Strength",0,65,round(window:GetGlassTintStrength()*100),
            {noConfig=true,format=function(v)return round(v).."%"end}
        )
        page.Controls.GlassTintStrength:OnChanged(function(v)window:SetGlassTintStrength(v/100)end)
    end
    if window.SetSurfaceHighlights then
        page.Controls.SurfaceHighlights=style:Toggle("Glass Highlights",window.surfaceHighlights~=false,{noConfig=true})
        page.Controls.SurfaceHighlights:OnChanged(function(v)window:SetSurfaceHighlights(v)end)
    end

    windowFx:AddLabel("Window geometry and background effects.",{muted=true,wrap=true,maxLines=2})
    page.Controls.Scale=windowFx:Slider(
        "UI Scale",55,165,round(window:GetScale()*100),
        {noConfig=true,format=function(v)return round(v).."%"end}
    )
    page.Controls.Scale:OnChanged(function(v)window:SetScale(v/100)end)

    page.Controls.BackgroundBlur=windowFx:Toggle("Background Blur",window.backgroundBlur==true,{noConfig=true})
    page.Controls.BackgroundBlur:OnChanged(function(v)window:SetBackgroundBlur(v)end)

    page.Controls.BackgroundSnow=windowFx:Toggle("Background Snow",window.backgroundSnow==true,{noConfig=true})
    page.Controls.BackgroundSnow:OnChanged(function(v)window:SetBackgroundSnow(v)end)

    local corners=Fawn.CornerPresets or{"Square","Tight","Soft","Round"}
    local cornerDefault="Round"
    page.Controls.CornerPreset=windowFx:Dropdown("Corner Preset",corners,indexOf(corners,cornerDefault)or 1,{noConfig=true})
    page.Controls.CornerPreset:OnChanged(function(v)if window.SetCornerPreset then window:SetCornerPreset(v)end end)

    if window.SetRadiusScale then
        page.Controls.RadiusScale=windowFx:Slider(
            "Radius Scale",45,165,round((window.radiusScale or 1)*100),
            {noConfig=true,format=function(v)return round(v).."%"end}
        )
        page.Controls.RadiusScale:OnChanged(function(v)window:SetRadiusScale(v/100)end)
    end

    page.Controls.Outline=windowFx:ColorPicker("Outline Color",window:GetOutlineColor(),{noConfig=true})
    page.Controls.Outline:OnChanged(function(v)
        window:SetOutlineColor(v)
        window:SetThemeColor("outline",v,true)
    end)

    page.Controls.OutlineStrength=windowFx:Slider(
        "Outline Thickness",25,300,round(window:GetOutlineStrength()*100),
        {noConfig=true,format=function(v)return format("%.2fx",v/100)end}
    )
    page.Controls.OutlineStrength:OnChanged(function(v)window:SetOutlineStrength(v/100)end)

    if window.SetOutlineOpacity then
        page.Controls.OutlineOpacity=windowFx:Slider(
            "Outline Opacity",15,100,round((window.outlineOpacity or 1)*100),
            {noConfig=true,format=function(v)return round(v).."%"end}
        )
        page.Controls.OutlineOpacity:OnChanged(function(v)window:SetOutlineOpacity(v/100)end)
    end

    windowFx:AddButtonPair(
        "Center UI",function()window:Center()end,
        "Default Size",function()window:SetSize(REF.Width,REF.Height)end
    )

    behavior:AddLabel("Input, animation and scrolling behavior.",{muted=true,wrap=true,maxLines=2})
    page.Controls.Smooth=behavior:Toggle("Smooth Scrolling",window.smoothScroll,{noConfig=true})
    page.Controls.Smooth:OnChanged(function(v)window:SetSmoothScroll(v)end)

    page.Controls.Anim=behavior:Toggle("Animations",window.animations,{noConfig=true})
    page.Controls.Anim:OnChanged(function(v)window:SetAnimations(v)end)

    if window.SetMotionStyle then
        local motions=Fawn.MotionStyles or{"Off","Minimal","Smooth","Snappy","Fluid"}
        page.Controls.MotionStyle=behavior:Dropdown(
            "Animation Style",motions,indexOf(motions,window.motionStyle or"Smooth")or 1,{noConfig=true}
        )
        page.Controls.MotionStyle:OnChanged(function(v)window:SetMotionStyle(v)end)
    end

    page.Controls.MotionSpeed=behavior:Slider("Animation Speed",4,30,round(window.animationSpeed or 10),{noConfig=true})
    page.Controls.MotionSpeed:OnChanged(function(v)window:SetAnimationSpeed(v)end)

    if window.SetHoverAnimations then
        page.Controls.HoverAnimations=behavior:Toggle("Animated Hovers",window.hoverAnimations~=false,{noConfig=true})
        page.Controls.HoverAnimations:OnChanged(function(v)window:SetHoverAnimations(v)end)
    end
    if window.SetSwitchAnimations then
        page.Controls.SwitchAnimations=behavior:Toggle("Animated Switches",window.switchAnimations~=false,{noConfig=true})
        page.Controls.SwitchAnimations:OnChanged(function(v)window:SetSwitchAnimations(v)end)
    end

    page.Controls.ScrollSpeed=behavior:Slider("Scroll Speed",1,30,window:GetScrollSpeed(),{noConfig=true})
    page.Controls.ScrollSpeed:OnChanged(function(v)window:SetScrollSpeed(v)end)

    local np=indexOf(Fawn.NotificationPositions,window:GetNotificationPosition())or 4
    page.Controls.Notifications=behavior:Dropdown("Notification Corner",Fawn.NotificationPositions,np,{noConfig=true})
    page.Controls.Notifications:OnChanged(function(v)window:SetNotificationPosition(v)end)

    page.Controls.MenuKey=behavior:Keybind(
        "Menu Key",window.toggleKey,
        {label=window.toggleLabel,mode="Toggle",keyboardOnly=true,keybindList=false,noConfig=true}
    )
    page.Controls.MenuKey:OnKeyChanged(function(k,l)window:SetToggleKey(k,l)end)

    profile:AddLabel("Identity and image assets used by the menu.",{muted=true,wrap=true,maxLines=2})
    page.Controls.ProfileName=profile:Input("Username",window.profileName,{placeholder="User",noConfig=true})
    page.Controls.ProfileName:OnChanged(function(v)window:SetProfileName(v)end)

    page.Controls.ProfileSub=profile:Input("Profile Subtitle",window.profileSubtitle,{placeholder="Developer",noConfig=true})
    page.Controls.ProfileSub:OnChanged(function(v)window:SetProfileSubtitle(v)end)

    local function imageOpts(kind,empty)
        local q=Fawn:ListStorage(kind)
        if #q==0 then return{empty}end
        return q
    end

    profile:AddSeparator("PROFILE PICTURE")
    page.Controls.ProfileBrowser=profile:Dropdown(
        "Profile Picture",imageOpts("ProfilePictures","(no profile pictures)"),1,{noConfig=true}
    )
    profile:AddButtonPair(
        "Apply Picture",function()
            local v=page.Controls.ProfileBrowser:Get()
            local ok,err=window:ApplyProfileImage(v)
            window:Notify(ok and("Applied "..tostring(v))or("Picture failed: "..tostring(err or"unknown error")),
                {title="PROFILE PICTURE",duration=4})
        end,
        "Clear Avatar",function()window:ClearProfileImage()end
    )

    profile:AddSeparator("BRAND")
    page.Controls.Brand=profile:Input("Brand Title",window.brand,{noConfig=true})
    page.Controls.Brand:OnChanged(function(v)window.brand=v end)
    page.Controls.Subtitle=profile:Input("Brand Subtitle",window.subtitle,{noConfig=true})
    page.Controls.Subtitle:OnChanged(function(v)window.subtitle=v end)

    page.Controls.LogoBrowser=profile:Dropdown(
        "Logo Picture",imageOpts("LogoPictures","(no logo pictures)"),1,{noConfig=true}
    )
    profile:AddButtonPair(
        "Apply Logo",function()
            local v=page.Controls.LogoBrowser:Get()
            local ok,err=window:ApplyLogoImage(v)
            window:Notify(ok and("Applied "..tostring(v))or("Logo failed: "..tostring(err or"unknown error")),
                {title="LOGO",duration=4})
        end,
        "Clear Logo",function()window:ClearLogoImage()end
    )
    profile:AddButton("Refresh Images",function()page:RefreshBrowsers()end)

    colors:AddLabel(
        "Fine tune the full palette. Theme changes refresh these values automatically.",
        {controlColumn=1,controlRow=1,span=2,muted=true,wrap=true,maxLines=2}
    )

    local colorDefs={
        {"Accent","accent"},{"Main Background","menuBg"},
        {"Card Background","card"},{"Control Background","control"},
        {"Control Hover","controlHover"},{"Active Item","activeItem"},
        {"Text","text"},{"Muted Text","muted"},
        {"Navigation Text","navText"},{"Popup","popup"},
        {"Icon","icon"},{"Chevron","chev"},
        {"Toggle Track","toggleTrack"},{"Toggle Knob","toggleKnob"},
        {"Logo Background","logoBg"},{"Logo Foreground","logoFg"},
        {"Avatar","avatar"},{"Avatar Dark","avatarDark"},
        {"Separator Line","line"}
    }

    page.ColorControls={}
    for i,d in ipairs(colorDefs)do
        local label,key=d[1],d[2]
        local col=((i-1)%2)+1
        local row=floor((i-1)/2)+2
        local cp=colors:ColorPicker(label,window:_color(key),{
            noConfig=true,controlColumn=col,controlRow=row
        })
        cp:OnChanged(function(v)window:SetThemeColor(key,v,true)end)
        page.ColorControls[key]=cp
    end

    function page:_syncColors()
        for k,c in pairs(self.ColorControls or{})do
            c:Set(window:_color(k),true)
        end
        if self.Controls.Outline then
            self.Controls.Outline:Set(window:GetOutlineColor(),true)
        end
    end

    local colorButtonRow=floor((#colorDefs-1)/2)+3
    colors:AddButtonPair(
        "Reset Appearance",function()
            window:SetTheme("Modern Blue")
            window:SetScale(1)
            window:SetLiquidGlass(false)
            window:SetOutlineStrength(1)
            window:SetBackgroundBlur(false)
            window:SetBackgroundSnow(false)
            if window.ResetPolish then window:ResetPolish()end
            if page.Controls.Theme then
                page.Controls.Theme:Set(indexOf(Fawn.ThemeNames,window:GetThemeName())or 1,true)
            end
            if page.Controls.BackgroundBlur then page.Controls.BackgroundBlur:Set(false,true)end
            if page.Controls.BackgroundSnow then page.Controls.BackgroundSnow:Set(false,true)end
            page:_syncColors()
        end,
        "Refresh Palette",function()page:_syncColors()end,
        {controlColumn=1,controlRow=colorButtonRow,span=2}
    )

    local cfgs=Fawn:ListStorage("Configs")
    if #cfgs==0 then cfgs={"(no config files)"}end
    page.Controls.ConfigBrowser=config:Dropdown("Config File",cfgs,1,{noConfig=true})
    page.Controls.ConfigBrowser:OnChanged(function(v)
        if v and v:sub(1,1)~="("then page:SetConfigPath(v)end
    end)
    page.Controls.ConfigName=config:Input(
        "New Config Name","default.lua",
        {placeholder="default.lua",noConfig=true,maxLength=96}
    )

    config:AddButtonPair(
        "Save As",function()
            page:SetConfigPath(page.Controls.ConfigName:Get())
            page:SaveConfig()
            page:RefreshBrowsers()
        end,
        "Load Selected",function()
            local v=page.Controls.ConfigBrowser:Get()
            if v and v:sub(1,1)~="("then
                page:SetConfigPath(v)
                page:LoadConfig()
            end
        end
    )
    config:AddButtonPair(
        "Refresh Files",function()page:RefreshBrowsers()end,
        "Show Path",function()page:ShowConfigPath()end
    )
    config:AddSeparator("IN-MEMORY")
    config:AddButtonPair(
        "Save Current",function()
            window:SaveNamedConfig(window.configName)
            window:Notify("Named config saved",{title="CONFIG"})
        end,
        "Duplicate",function()
            local n=window:DuplicateNamedConfig()
            window:Notify("Created "..n,{title="CONFIG"})
        end
    )
    config:AddValue("Configs Folder",function()local p=Fawn:GetStoragePaths();return p.Configs or"Fawn Modern/configs"end,{muted=true,wrap=true,maxLines=2})

    diagnostics:AddValue("Paint Frames",function()return Fawn:GetPaintCount()end)
    diagnostics:AddValue("Paint Errors",function()
        local n=Fawn:GetPaintErrors()
        return tostring(n)
    end)
    diagnostics:AddValue("Draw Errors",function()return tostring(E.drawErrors or 0)end)
    diagnostics:AddValue("Window Size",function()
        local w,h=window:GetSize()
        return round(w).." × "..round(h)
    end)
    diagnostics:AddValue("UI Scale",function()return round(window:GetScale()*100).."%"end)
    diagnostics:AddValue("Active Theme",function()return window:GetThemeName()end,{accent=true})
    diagnostics:AddButton("Test Notification",function()
        window:Notify("Settings page is live and working.",{title="FAWN SETTINGS"})
    end)

    local perfModes={"Peak","Balanced","Safe"}
    page.Controls.PerformanceMode=performance:Dropdown("Performance Mode",perfModes,indexOf(perfModes,Fawn:GetPerformanceMode())or 1,{noConfig=true,controlColumn=1,controlRow=1})
    page.Controls.PerformanceMode:OnChanged(function(v)
        Fawn:SetPerformanceMode(v)
        if page.Controls.FastDraw then page.Controls.FastDraw:Set(Fawn:GetFastDraw(),true)end
        if page.Controls.SnowBudget then page.Controls.SnowBudget:Set(Fawn:GetSnowParticleCount(),true)end
    end)
    page.Controls.FastDraw=performance:Toggle("Fast Draw",Fawn:GetFastDraw(),{noConfig=true,controlColumn=2,controlRow=1})
    page.Controls.FastDraw:OnChanged(function(v)Fawn:SetFastDraw(v)end)
    page.Controls.SnowBudget=performance:Slider("Snow Particle Budget",0,120,Fawn:GetSnowParticleCount(),{noConfig=true,step=1,controlColumn=1,controlRow=2})
    page.Controls.SnowBudget:OnChanged(function(v)Fawn:SetSnowParticleCount(v)end)
    performance:AddValue("Text / Fit Cache",function()local q=Fawn:GetPerformanceStats();return tostring(q.measureCache or 0).." / "..tostring(q.fitCache or 0)end,{controlColumn=2,controlRow=2})
    performance:AddValue("Color Cache",function()local q=Fawn:GetPerformanceStats();return tostring(q.rgbCache or 0)end,{controlColumn=1,controlRow=3})
    performance:AddValue("Runtime Errors",function()local q=Fawn:GetPerformanceStats();return tostring(q.paintErrors or 0).." paint / "..tostring(q.drawErrors or 0).." draw"end,{controlColumn=2,controlRow=3})
    performance:AddLabel("Peak is the default. Balanced raises the snow budget. Safe restores per-draw protected calls and full key polling for debugging unusual runtime issues.",{controlColumn=1,controlRow=4,span=2,wrap=true,maxLines=3})

    function page:RefreshBrowsers()
        local function apply(ctrl,list,empty)
            local q=list
            if #q==0 then q={empty}end
            if ctrl then ctrl:SetOptions(q,{preserve="text"})end
        end
        apply(self.Controls.ConfigBrowser,Fawn:ListStorage("Configs"),"(no config files)")
        apply(self.Controls.ProfileBrowser,Fawn:ListStorage("ProfilePictures"),"(no profile pictures)")
        apply(self.Controls.LogoBrowser,Fawn:ListStorage("LogoPictures"),"(no logo pictures)")
        return self
    end

    page:CaptureDefaults()
    window.settingsPage=page
    page:RefreshBrowsers()
    return page
end

function Fawn:SetPerformanceMode(mode)
    local key=lower(tostring(mode or"Peak"));local P=self.Performance
    if key=="safe"then P.Mode="Safe";P.FastDraw=false;P.SmartKeyPolling=false;P.SnowParticles=70;P.ImageRetryMs=2500
    elseif key=="balanced"then P.Mode="Balanced";P.FastDraw=false;P.SmartKeyPolling=true;P.SnowParticles=56;P.ImageRetryMs=4000
    else P.Mode="Peak";P.FastDraw=false;P.SmartKeyPolling=true;P.SnowParticles=48;P.ImageRetryMs=5000 end
    for _,w in ipairs(E.windows)do if w and not w.destroyed then w._snowFix=nil end end
    return self
end
function Fawn:GetPerformanceMode()return self.Performance.Mode end
function Fawn:SetSnowParticleCount(v)self.Performance.SnowParticles=clamp(floor(tonumber(v)or self.Performance.SnowParticles),0,120);for _,w in ipairs(E.windows)do if w and not w.destroyed then w._snowFix=nil end end;return self end
function Fawn:GetSnowParticleCount()return self.Performance.SnowParticles end
function Fawn:SetFastDraw(v)
    -- Kept for API compatibility. Native draw bypass is intentionally disabled;
    -- all draw calls remain protected in every profile.
    self.Performance.FastDraw=false
    return self
end
function Fawn:GetFastDraw()return self.Performance.FastDraw==true end
function Fawn:GetPerformanceStats()local P=self.Performance;return{mode=P.Mode,fastDraw=P.FastDraw,smartKeyPolling=P.SmartKeyPolling,snowParticles=P.SnowParticles,imageRetryMs=P.ImageRetryMs,measureCache=measureCount,fitCache=P.FitCount,rgbCache=P.RGBCount,windows=#E.windows,overlays=#E.overlays,notifications=#E.notifications,paintCount=E.paintCount,paintErrors=E.paintErrors,drawErrors=E.drawErrors}end

Fawn.DynamicCapabilities=Fawn.DynamicCapabilities or{}
Fawn.DynamicCapabilities.PeakPerformanceCore=true
Fawn.DynamicCapabilities.SmartKeyPolling=true
Fawn.DynamicCapabilities.ColorObjectCache=true
Fawn.DynamicCapabilities.TextLayoutCache=true
Fawn.Runtime=Fawn.Runtime or{}
Fawn.Runtime.Performance="Peak mode keeps protected native drawing while using cached Color3/text geometry, smart key polling, frame-value caching, reusable layout rectangles, bounded image retries and reduced effect budgets"

Fawn.DynamicCapabilities=Fawn.DynamicCapabilities or{}
Fawn.DynamicCapabilities.PremadeSettingsPage=true
Fawn.DynamicCapabilities.AccessoryPopupModalChildren=true
Fawn.DynamicCapabilities.AccessoryColorPicker=true
Fawn.DynamicCapabilities.AccessorySliderNumericEntry=true
Fawn.DynamicCapabilities.SliderManualOverflow=true
Fawn.DynamicCapabilities.PopupTriggerToggle=true
Fawn.DynamicCapabilities.CaretPixelAlignment=true
Fawn.DynamicCapabilities.AccessoryColorPopupInteractive=true
Fawn.Runtime=Fawn.Runtime or{}
Fawn.Runtime.SettingsPage="polished live style/effects/motion/profile/colors/config/diagnostics page"
Fawn.Runtime.AccessoryPopupFinal="nested dropdown/color/key menus are modal and cannot click through"
Fawn.Runtime.SliderNumericEntry="typed values may exceed visual range unless Control:SetClamp(true) is enabled"
Fawn.Runtime.PopupTriggerToggle="dropdowns, color pickers and three-dot accessory menus close when their trigger is clicked again"
Fawn.Runtime.CaretPixelAlignment="caret width uses draw.Text rounded font size + floored text origin; clicking text places the caret at the nearest character"

Fawn.DynamicCapabilities=Fawn.DynamicCapabilities or{}
Fawn.DynamicCapabilities.ResponsiveSecondaryWindows=true
Fawn.DynamicCapabilities.PersistentESPElementCapture=true
Fawn.DynamicCapabilities.DockedESPDragOwnership=true
Fawn.DynamicCapabilities.BackgroundEffects=true
Fawn.DynamicCapabilities.ManagedImageFallbackDraw=true
Fawn.Runtime=Fawn.Runtime or{}
Fawn.Runtime.ESPElementDrag="docked ESP stays owned by its parent Window while dragging; standalone ESP stays overlay-owned"
Fawn.Runtime.SecondaryUI="responsive topbar + automatic narrow-column reflow + bounded panel header"
Fawn.Runtime.ManagedImages="sandbox-normalized paths + LoadImage cache + 5-arg draw.Image compatibility + timed retry"

Fawn.Runtime.BackgroundEffects="original Fawn-style dim backdrop + lightweight snow"

-- ============================================================================
-- 10.x final hardening: modal accessories, clean optional ESP, neutral assets,
-- and Peak hot-path rendering.
-- ============================================================================

Fawn.Performance.ColorPickerCols=14
Fawn.Performance.ColorPickerRows=10
Fawn.Performance.ColorPickerHueSteps=24
Fawn.Performance.ColorPickerAlphaSteps=48
Fawn.Performance.PeakStaticSurfaces=true
Fawn.Performance.ReuseControlRects=true

-- In Peak + Solid mode, skip the expensive per-surface animation/material
-- machinery. Widget hover states still work because controls select their own
-- theme role (control/controlHover/activeItem) before reaching this function.
local ultraFillBase=Window._fill
function Window:_fill(role,x,y,w,h,key,r,a)
    local P=Fawn.Performance
    if P.Mode=="Peak"and P.PeakStaticSurfaces~=false and not self.liquidGlass and(self.surfaceStyle==nil or self.surfaceStyle=="Solid")then
        local c=self:_color(key)
        local aa=a
        if aa==nil then aa=alphaFor(self,role,c[4]or 255)end
        rect(x,y,w,h,c,max(0,(tonumber(r)or 0)*(self.radiusScale or 1)),aa)
        return
    end
    return ultraFillBase(self,role,x,y,w,h,key,r,a)
end

local ultraOutBase=Window._out
function Window:_out(x,y,w,h,r,t,c,a)
    local P=Fawn.Performance
    if P.Mode=="Peak"and P.PeakStaticSurfaces~=false and not self.liquidGlass and(self.surfaceStyle==nil or self.surfaceStyle=="Solid")then
        local rr=max(0,(tonumber(r)or 0)*(self.radiusScale or 1))
        local th=max(.75,(tonumber(t)or self.borderThickness or 1)*(self.outlineStrength or 1))
        local aa=clamp((tonumber(a)or 255)*(self.outlineOpacity or 1),0,255)
        outline(x,y,w,h,c or self.outlineColor or self:_color("outline"),rr,aa,th)
        return
    end
    return ultraOutBase(self,x,y,w,h,r,t,c,a)
end

-- Reuse one rectangle per control and walk Section.controls in authored order.
-- This removes the per-frame rows={} allocation + table.sort from every visible
-- Section while preserving exact authored control ordering.
function Window:_drawSection(box,bodyTop,bodyBottom,bodyLeft,bodyRight)
    local sec=box.section
    local s=self.scale
    local cardTop=box.cardY
    local cardBottom=cardTop+box.cardH
    local clipL=max(bodyLeft or box.x,box.x)
    local clipR=min(bodyRight or(box.x+box.w),box.x+box.w)
    local clipT=max(bodyTop,cardTop)
    local clipB=min(bodyBottom,cardBottom)
    if clipB<=clipT or clipR<=clipL then return end

    if sec._scrollDrag then
        if Input.left and sec.maxScroll>0 then
            local rr=snapRatio96((Input.my-sec._scrollDrag.top-sec._scrollDrag.off)/max(1,sec._scrollDrag.span))
            sec.scrollTarget=rr*sec.maxScroll
            sec.scroll=sec.scrollTarget
        else
            sec._scrollDrag=nil
            sec.scroll,sec.scrollTarget=settle96(sec.scroll,sec.scrollTarget,sec.maxScroll,self.scrollSpeed,s,false)
        end
    else
        sec.scroll,sec.scrollTarget=settle96(sec.scroll,sec.scrollTarget,sec.maxScroll,self.scrollSpeed,s,false)
    end

    local rr=min(14*s,(clipB-clipT)*.5,(clipR-clipL)*.5)
    self:_fill("card",clipL,clipT,clipR-clipL,clipB-clipT,"card",rr)

    local offset=sec.scroll or 0
    for _,c in ipairs(sec.controls or{})do
        local base=box.layouts[c]
        if base and alive(c)and visibilityPass(c)then
            local r=c._fawnFastRect
            if not r then r={};c._fawnFastRect=r end
            r.x,r.y,r.w,r.h=base.x,base.y-offset,base.w,base.h
            if r.y>=clipT-.25 and r.y+r.h<=clipB+.25 and r.x>=clipL-.25 and r.x+r.w<=clipR+.25 then
                self:_drawControl(c,r,clipT,clipB)
            end
        end
    end

    if sec.columnDividers==true and sec.columns and sec.columns>1 then
        local gap=(sec.controlGap or 12)*s
        local usable=box.w-(((sec.sizeMode=="fixed"or sec.sizeMode=="fill"or sec.maxHeight)and REF.SectionScrollbarGutter or 0)*s)
        local cw=(usable-gap*(sec.columns-1))/sec.columns
        for i=1,sec.columns-1 do
            local xx=box.x+i*cw+(i-.5)*gap
            local y1=max(clipT+8*s,cardTop+8*s)
            local y2=min(clipB-8*s,cardBottom-8*s)
            if y2>y1 then line(xx,y1,xx,y2,self:_color("line"),1,14)end
        end
    end

    if sec.maxScroll>1 then
        local gutter=REF.SectionScrollbarGutter*s
        local gx=box.x+box.w-gutter
        local tx=gx+gutter*.5
        local top=clipT+9*s
        local bh=max(1,clipB-clipT-18*s)
        local thumb=max(28*s,bh*(box.cardH/max(box.cardH,box.contentH)))
        local span=max(1,bh-thumb)
        local ratio=sec.maxScroll>0 and snapRatio96((sec.scroll or 0)/sec.maxScroll)or 0
        local ty=top+span*ratio
        local trackHover=self:_hit(gx,clipT,gutter,clipB-clipT)
        local thumbHover=self:_hit(gx,ty-3*s,gutter,thumb+6*s)
        local active=sec._scrollDrag~=nil
        if trackHover or active then rect(tx-1*s,top,2*s,bh,self:_color("controlHover"),1*s,88)end
        rect(tx-((active or thumbHover)and 2*s or 1.5*s),ty,(active or thumbHover)and 4*s or 3*s,thumb,self:_color((active or thumbHover)and"accent"or"outline"),2*s,(active or thumbHover)and 255 or 180)
        if Input.click and not self._consumed and not self:_hasPopup()and thumbHover then
            sec._scrollDrag={top=top,span=span,off=Input.my-ty}
            self:_consume()
        end
    else
        sec._scrollDrag=nil
        sec.scroll,sec.scrollTarget=0,0
    end

    self:_out(clipL,clipT,clipR-clipL,clipB-clipT,rr,.82,self:_color("outline"),112)
    local titleY=box.y+7*s
    if titleY>=bodyTop-20*s and titleY<=bodyBottom and box.x>=bodyLeft-1 and box.x<=(bodyRight or box.x+box.w)then
        textC(fit(upper(sec.name),max(20,box.w-44*s),14*s,"Verdana"),box.x+22*s,titleY,self:_color("muted"),14*s,"Verdana")
    end
end

-- Popups get exclusive pointer access over the page underneath them. This is
-- stronger than relying on every individual control to remember `_hasPopup()`.
local ultraDrawContent=Window._drawContent
function Window:_drawContent()
    local hadPopup=self:_hasPopup()
    if not hadPopup then return ultraDrawContent(self)end

    -- The normal content pass is pointer-silent while a popup is open. Handle
    -- the one legitimate content-layer click here: clicking the same outer
    -- three-dot trigger closes the accessory menu. The click is still suppressed
    -- for the rest of this frame so the underlying control cannot reopen it.
    if self.extraPopup and Input.click and not self._consumed then
        local p=self.extraPopup
        if p.triggerX and p.triggerY and p.triggerW and p.triggerH and self:_hit(p.triggerX,p.triggerY,p.triggerW,p.triggerH)then
            self.extraPopup=nil
            self.openDrop=nil;self.colorPopup=nil;self.colorMenu=nil;self.keyMenu=nil
            self:_consume()
        end
    end

    local click,rightClick,left,right,released,rightReleased,wheel=
        Input.click,Input.rightClick,Input.left,Input.right,Input.released,Input.rightReleased,Input.wheel
    Input.click,Input.rightClick,Input.left,Input.right,Input.released,Input.rightReleased,Input.wheel=false,false,false,false,false,false,0
    local ok,a,b,c,d=pcall(ultraDrawContent,self)
    Input.click,Input.rightClick,Input.left,Input.right,Input.released,Input.rightReleased,Input.wheel=
        click,rightClick,left,right,released,rightReleased,wheel
    if not ok then error(a)end
    return a,b,c,d
end

local function ultraAccessoryRows(parent)
    local n=0
    local k=parent and parent.keybind
    if k and not k.accessoryOnly then n=n+1 end
    local controls=parent and parent.extraSection and parent.extraSection.controls
    if controls then for _,c in ipairs(controls)do if alive(c)and visibilityPass(c)then n=n+1 end end end
    return n
end

local function ultraSliderCaret(win,ed,shown,vx,vw,cy,C)
    local tw=measure(shown,C.valFont*win.scale,"Verdana")
    local ex=floor(vx+(vw-tw)*.5)
    textC(shown,ex,cy,win:_color("text"),C.valFont*win.scale,"Verdana")
    if(nowMs()-(ed.blink or 0))%900<450 then
        local cursor=clamp(ed.cursor or#shown,0,#shown)
        local pre=sub(shown,1,cursor)
        local preW=caretWidth(pre,C.valFont*win.scale,"Verdana")
        local cx=clamp(ex+floor(preW+.5),floor(vx+2*win.scale),floor(vx+vw-2*win.scale))
        caretLine(cx,cy,shown,C.valFont*win.scale,"Verdana",win:_color("text"),255)
    end
end

-- Final accessory row implementation. Child dropdown/color/key menus are true
-- nested modals; numeric slider boxes are editable by left OR right click.
local function ultraAccessoryRow(win,c,x,y,w,h,C,canInteract)
    local s=win.scale
    local left=x+C.padL*s
    local right=x+w-C.padR*s
    local cy=y+h*.5
    local labelW=max(30*s,w*.40)
    if c.type~="button"and c.type~="label"and c.type~="separator"then
        textC(fit(c.label or"",labelW,C.font*s,"Verdana"),left,cy,win:_color("text"),C.font*s,"Verdana")
    end

    if c.type=="toggle"then
        local tw,th=C.togW*s,C.togH*s
        local tx,ty=right-tw,cy-C.togH*s*.5
        local on=c.value==true
        rect(tx,ty,tw,th,on and win:_color("accent")or win:_color("toggleTrack"),th*.5,255)
        local kp=(th-C.knob*s)*.5
        circle(on and(tx+tw-kp-C.knob*s*.5)or(tx+kp+C.knob*s*.5),cy,C.knob*s*.5,win:_color("white"),255)
        if canInteract and Input.click and not win._consumed and win:_hit(tx,ty,tw,th)then c:Set(not on);win:_consume()end
        return
    end

    if c.type=="slider"then
        local editing=win.sliderEdit and win.sliderEdit.control==c
        local display=win:_sliderDisplay(c,c.value or c.min)
        local shown=editing and tostring(win.sliderEdit.text or"")or display
        local textW=measure(shown,C.valFont*s,"Verdana")
        local vw=max((editing and 78 or 54)*s,textW+C.valPad*2*s)
        local vx=right-vw
        local vh=C.valH*s
        local vy=cy-vh*.5
        local sx=left+labelW
        local sw=max(34*s,vx-C.sGap*s-sx)
        rect(sx,cy-2*s,sw,4*s,win:_color("control"),2*s,255)
        local range=max(.00001,c.max-c.min)
        local q=clamp((clamp(c.value or c.min,c.min,c.max)-c.min)/range,0,1)
        local kx=sx+q*sw
        rect(sx,cy-2*s,max(0,kx-sx),4*s,win:_color("accent"),2*s,255)
        circle(kx,cy,max(4*s,C.sKnob*s*.32),win:_color("white"),255)

        local valueHover=win:_hit(vx,vy,vw,vh)
        win:_fill("control",vx,vy,vw,vh,(editing or valueHover)and"controlHover"or"control",C.valR*s)
        if editing then
            win:_out(vx,vy,vw,vh,C.valR*s,1,win:_color("accent"),255)
            ultraSliderCaret(win,win.sliderEdit,shown,vx,vw,cy,C)
        else
            textC(display,vx+(vw-textW)*.5,cy,win:_color("text"),C.valFont*s,"Verdana")
        end

        if c._accessoryDrag then
            if Input.left then c:Set(c.min+clamp((Input.mx-sx)/max(1,sw),0,1)*(c.max-c.min))
            else c._accessoryDrag=nil end
        end

        if canInteract and not win._consumed then
            if (Input.click or Input.rightClick)and valueHover then
                if not editing then win:_startSliderEdit(c,{vx,vy,vw,vh})end
                local ed=win.sliderEdit
                if ed and ed.control==c then
                    local txt=tostring(ed.text or"")
                    local tw=measure(txt,C.valFont*s,"Verdana")
                    local tx=floor(vx+(vw-tw)*.5)
                    local localX=clamp(Input.mx-tx,0,max(0,tw))
                    local best,bestDist=0,abs(localX)
                    for p=1,#txt do
                        local pw=caretWidth(sub(txt,1,p),C.valFont*s,"Verdana")
                        local dist=abs(localX-pw)
                        if dist<=bestDist then best,bestDist=p,dist else break end
                    end
                    ed.cursor=best;ed.blink=nowMs()
                end
                win:_consume()
            elseif Input.click and win:_hit(sx,cy-15*s,sw,30*s)and not editing then
                c._accessoryDrag=true
                c:Set(c.min+clamp((Input.mx-sx)/max(1,sw),0,1)*(c.max-c.min))
                win:_consume()
            end
        end
        return
    end

    if c.type=="dropdown"or c.type=="multiselect"then
        local fw=min(148*s,max(86*s,w*.48))
        local fh=C.ddH*s
        local fx,fy=right-fw,cy-fh*.5
        local hov=win:_hit(fx,fy,fw,fh)
        local opened=win.openDrop and win.openDrop.control==c
        win:_fill("control",fx,fy,fw,fh,(hov or opened)and"controlHover"or"control",C.ddR*s)
        local textv=c.type=="multiselect"and c:GetSummary()or tostring(c:Get()or"None")
        textC(fit(textv,fw-34*s,C.ddFont*s,"Verdana"),fx+C.ddPadL*s,cy,win:_color("text"),C.ddFont*s,"Verdana")
        chevDown(fx+fw-C.ddPadR*s-C.chev*s*.5,cy,C.chev*s,win:_color("chev"),opened)
        if (canInteract or opened)and Input.click and not win._consumed and hov then
            if opened then win.openDrop=nil else win:_openDropdown(c,fx,fy,fw,fh);win.openDrop.accessoryParent=win.extraPopup and win.extraPopup.control end
            win:_consume()
        end
        return
    end

    if c.type=="color"then
        local own=(win.colorPopup and win.colorPopup.control==c)or(win.colorMenu and win.colorMenu.control==c)
        win:_drawColorChip(c,right,cy,C,canInteract or own,true)
        return
    end

    if c.type=="keybind"then
        local shown=win:_keyLabel(c)
        local tw=measure(shown,C.keyFont*s,"Verdana")
        local fw=min(138*s,max(76*s,tw+C.keyPad*2*s))
        local fh=C.keyH*s
        local fx,fy=right-fw,cy-fh*.5
        local hov=win:_hit(fx,fy,fw,fh)
        win:_fill("control",fx,fy,fw,fh,hov and"controlHover"or"control",C.keyR*s)
        textC(shown,fx+(fw-tw)*.5,cy,win.captureBind==c and win:_color("accent")or win:_color("text"),C.keyFont*s,"Verdana")
        if canInteract and Input.click and not win._consumed and hov then win.captureBind=c;win._captureFrame=E.paintCount;win:_consume()
        elseif canInteract and Input.rightClick and not win._consumed and hov then win.keyMenu={control=c,x=fx,y=fy+fh+5*s,w=162*s,h=3*C.itemH*s,accessoryParent=win.extraPopup and win.extraPopup.control};win:_consume()end
        return
    end

    if c.type=="input"then
        local fw=min(150*s,max(86*s,w*.48))
        local fh=C.ddH*s
        local fx,fy=right-fw,cy-fh*.5
        local hov=win:_hit(fx,fy,fw,fh)
        win:_fill("control",fx,fy,fw,fh,hov and"controlHover"or"control",C.ddR*s)
        local focused=win.inputEdit and win.inputEdit.control==c
        local raw=tostring(c.value or"")
        local shown,caret=win:_visibleInputText(c,fw,C)
        local col=win:_color("text")
        if raw==""and not focused then shown=tostring(c.placeholder or"");col=win:_color("muted")end
        local textX=floor(fx+C.ddPadL*s)
        textC(shown,textX,cy,col,C.ddFont*s,"Verdana")
        if focused and(nowMs()-(win.inputEdit.blink or 0))%900<450 then
            local cx=clamp(textX+floor(caret+.5),textX-1,floor(fx+fw-C.ddPadR*s))
            caretLine(cx,cy,shown,C.ddFont*s,"Verdana",win:_color("accent"),255)
        end
        c._inputRect={fx,fy,fw,fh}
        if canInteract and Input.click and not win._consumed and hov then win:_focusInput(c);win:_consume()end
        return
    end

    if c.type=="button"then
        local bx,bw=left,right-left
        local bh=max(28*s,h-12*s)
        local by=cy-bh*.5
        local hov=win:_hit(bx,by,bw,bh)
        win:_fill("control",bx,by,bw,bh,hov and"controlHover"or"control",8*s)
        local label=fit(c.label,bw-18*s,C.font*s,"Verdana")
        local tw=measure(label,C.font*s,"Verdana")
        textC(label,bx+(bw-tw)*.5,cy,win:_color("text"),C.font*s,"Verdana")
        if canInteract and Input.click and not win._consumed and hov then if type(c.fn)=="function"then pcall(c.fn,c)end;win:_consume()end
        return
    end

    if c.type=="label"then
        local lines=wrapText(c.label,max(20,right-left),C.font*s,"Verdana",c.maxLines or 3)
        local lh=17*s;win:_drawWrapped(lines,left,cy-#lines*lh*.5,win:_color("text"),C.font*s,lh,false)
    elseif c.type=="separator"then
        textC(fit(upper(c.label),max(20,right-left),11*s,"Verdana"),left,cy,win:_color("muted"),11*s,"Verdana")
    end
end

function Window:_drawExtraPopup()
    local p=self.extraPopup
    if not p then return end
    local parent=p.control
    if not alive(parent)then self:_closePopups();return end

    local s=self.scale
    local C=REF.Compact
    local rowH=C.rowH*s
    local header=36*s
    local count=ultraAccessoryRows(parent)
    p.w=REF.AccessoryWidth*s
    p.h=header+max(1,count)*rowH+8*s
    p.anchorY=p.anchorY or p.y-8*s
    self:_clampPopup(p)
    self:_popupFrame(p)

    textC("ACCESSORIES",p.x+14*s,p.y+18*s,self:_color("muted"),12*s,"Verdana")
    local nested=self.openDrop or self.colorPopup or self.colorMenu or self.keyMenu
    local y=p.y+header
    local k=parent.keybind

    if k and not k.accessoryOnly then
        local shown=self:_keyLabel(k)
        local tw=measure(shown,C.keyFont*s,"Verdana")
        local fw=min(126*s,max(76*s,tw+C.keyPad*2*s))
        local fh=C.keyH*s
        local fx=p.x+p.w-C.padR*s-fw
        local fy=y+(rowH-fh)*.5
        local cy=y+rowH*.5
        local hov=self:_hit(fx,fy,fw,fh)
        textC("Keybind",p.x+C.padL*s,cy,self:_color("text"),C.font*s,"Verdana")
        self:_fill("control",fx,fy,fw,fh,hov and"controlHover"or"control",C.keyR*s)
        textC(shown,fx+(fw-tw)*.5,cy,self.captureBind==k and self:_color("accent")or self:_color("text"),C.keyFont*s,"Verdana")
        if not nested and Input.click and not self._consumed and hov then self.captureBind=k;self._captureFrame=E.paintCount;self:_consume()
        elseif not nested and Input.rightClick and not self._consumed and hov then self.keyMenu={control=k,x=fx,y=fy+fh+5*s,w=162*s,h=3*C.itemH*s,accessoryParent=parent};self:_consume()end
        y=y+rowH
    end

    local controls=parent.extraSection and parent.extraSection.controls or{}
    for _,c in ipairs(controls)do
        if alive(c)and visibilityPass(c)then
            local ownChild=(self.openDrop and self.openDrop.control==c)or(self.colorPopup and self.colorPopup.control==c)or(self.colorMenu and self.colorMenu.control==c)or(self.keyMenu and self.keyMenu.control==c)
            ultraAccessoryRow(self,c,p.x,y,p.w,rowH,C,(not nested)or ownChild)
            y=y+rowH
        end
    end

    -- The accessory shell is modal, but a child popup is drawn after it. Never
    -- consume a click that belongs to that child before the child gets to see it.
    if not self._consumed and(Input.click or Input.rightClick)and self:_hit(p.x,p.y,p.w,p.h)then
        if nested then
            local childInside=false
            for _,q in ipairs({self.openDrop,self.colorPopup,self.colorMenu,self.keyMenu})do
                if q then
                    if q.x and q.y and q.w and q.h and self:_hit(q.x,q.y,q.w,q.h)then childInside=true break end
                    if q.triggerX and q.triggerY and q.triggerW and q.triggerH and self:_hit(q.triggerX,q.triggerY,q.triggerW,q.triggerH)then childInside=true break end
                end
            end
            if not childInside then
                self.openDrop=nil;self.colorPopup=nil;self.colorMenu=nil;self.keyMenu=nil
                self:_consume()
            end
        else
            self:_consume()
        end
    end
end

-- Child color popup: lower draw-call gradient in Peak mode and immediate click
-- application before drag capture, so a picker works even on runtimes where a
-- click edge and held-state arrive on different callbacks.
function Window:_drawColorPopup()
    local p=self.colorPopup
    if not p then return end
    local c=p.control
    if not alive(c)then self.colorPopup=nil return end

    local s=self.scale
    local sw,sh=screenSize()
    local w,h=278*s,286*s
    local tx=p.triggerX or p.x or 8
    local ty=p.triggerY or p.y or 8
    local tw=p.triggerW or 20*s

    local x=tx+tw+10*s
    if x+w>sw-8 then x=tx-w-10*s end
    x=clamp(x,8,max(8,sw-w-8))
    local y=clamp(ty-14*s,8,max(8,sh-h-8))

    p.x,p.y,p.w,p.h=x,y,w,h

    local arr=c.value
    local hue,sat,val=rgbToHsv92(arr[1],arr[2],arr[3])
    local main=self:_color("menuBg")
    local card=self:_color("card")
    local border=self:_color("outline")
    local textCol=self:_color("text")
    local dim=self:_color("muted")
    local white=self:_color("white")

    local svx,svy,svw,svh=x+14*s,y+52*s,202*s,138*s
    local hx,hy,hw,hh=x+228*s,y+52*s,22*s,138*s
    local ax,ay,aw,ah=x+14*s,y+218*s,236*s,16*s

    -- Original Fawn popup shell/header.
    rect(x,y,w,h,main,11*s,252)
    self:_out(x,y,w,h,11*s,1,border,235)
    rect(x+1*s,y+1*s,w-2*s,40*s,card,10*s,245)
    line(x+12*s,y+40*s,x+w-12*s,y+40*s,border,max(1,s),180)
    text(c.label or"COLOR",x+14*s,y+15*s,textCol,13*s,"Verdana")

    -- Original live preview in the header.
    local pvx,pvy=x+w-72*s,y+11*s
    local pvw,pvh=42*s,20*s
    rect(pvx,pvy,pvw,pvh,card,6*s,255)
    self:_out(pvx,pvy,pvw,pvh,6*s,1,border,255)
    local pix,piy,piw,pih=pvx+3*s,pvy+3*s,pvw-6*s,pvh-6*s
    local tile=4*s
    for yy=0,max(0,ceil(pih/tile)-1)do
        for xx=0,max(0,ceil(piw/tile)-1)do
            local qx,qy=pix+xx*tile,piy+yy*tile
            local qw,qh=min(tile,pix+piw-qx),min(tile,piy+pih-qy)
            if qw>0 and qh>0 then
                rect(qx,qy,qw,qh,((xx+yy)%2==0)and{72,70,78,255}or{39,38,44,255},0,255)
            end
        end
    end
    rect(pix,piy,piw,pih,arr,4*s,arr[4]or 255)

    -- Close X, exactly like the original picker header.
    local closeX,closeY=x+w-18*s,y+20*s
    line(closeX-3*s,closeY-3*s,closeX+3*s,closeY+3*s,dim,max(1,s),255)
    line(closeX+3*s,closeY-3*s,closeX-3*s,closeY+3*s,dim,max(1,s),255)

    -- Original high-density SV field.
    rect(svx-1*s,svy-1*s,svw+2*s,svh+2*s,card,6*s,255)
    self:_out(svx-1*s,svy-1*s,svw+2*s,svh+2*s,6*s,1,border,210)
    local isvx,isvy,isvw,isvh=svx+1*s,svy+1*s,svw-2*s,svh-2*s
    local cols,rows=72,50
    local cw,ch=isvw/cols,isvh/rows
    for iy=0,rows-1 do
        local vv=1-(iy/(rows-1))
        for ix=0,cols-1 do
            local ss=ix/(cols-1)
            local r,g,b=hsvToRgb92(hue,ss,vv)
            rect(isvx+ix*cw,isvy+iy*ch,cw+1.05*s,ch+1.05*s,{r,g,b,255},0,255)
        end
    end
    local sx=isvx+sat*isvw
    local sy=isvy+(1-val)*isvh
    rect(sx-2*s,sy-2*s,4*s,4*s,white,2*s,255)

    -- Original full-height hue strip.
    rect(hx-1*s,hy-1*s,hw+2*s,hh+2*s,card,6*s,255)
    self:_out(hx-1*s,hy-1*s,hw+2*s,hh+2*s,6*s,1,border,210)
    local ihx,ihy,ihw,ihh=hx+1*s,hy+1*s,hw-2*s,hh-2*s
    local steps=138
    local hs=ihh/steps
    for i=0,steps-1 do
        local r,g,b=hsvToRgb92(i/(steps-1),1,1)
        rect(ihx,ihy+i*hs,ihw,hs+1.1*s,{r,g,b,255},0,255)
    end
    rect(hx-2*s,ihy+hue*ihh-1*s,hw+4*s,2*s,white,1*s,255)

    -- Original checkerboard transparency strip.
    text("TRANSPARENCY",ax,ay-18*s,dim,13*s,"Verdana")
    rect(ax,ay,aw,ah,card,6*s,255)
    self:_out(ax,ay,aw,ah,6*s,1,border,255)
    local iax,iay,iaw,iah=ax+2*s,ay+2*s,aw-4*s,ah-4*s
    local checker=6*s
    for yy=0,max(0,ceil(iah/checker)-1)do
        for xx=0,max(0,ceil(iaw/checker)-1)do
            local qx,qy=iax+xx*checker,iay+yy*checker
            local qw,qh=min(checker,iax+iaw-qx),min(checker,iay+iah-qy)
            if qw>0 and qh>0 then
                rect(qx,qy,qw,qh,((xx+yy)%2==0)and{72,70,78,255}or{39,38,44,255},0,255)
            end
        end
    end
    local gax,gay,gaw,gah=iax+1*s,iay+1*s,iaw-2*s,iah-2*s
    local pixels=max(1,floor(gaw))
    for i=0,pixels-1 do
        local aa=floor((i/max(1,pixels-1))*255+.5)
        rect(gax+i,gay,1,gah,{arr[1],arr[2],arr[3],255},0,aa)
    end
    rect(iax+iaw-5*s,iay,5*s,iah,{arr[1],arr[2],arr[3],255},4*s,255)
    local alphaX=gax+((arr[4]or 255)/255)*gaw
    rect(alphaX-1*s,gay-1*s,2*s,gah+2*s,white,1*s,255)

    -- Original hex / Alpha readouts.
    local hex=format("#%02X%02X%02X",arr[1],arr[2],arr[3])
    local ap=floor(((arr[4]or 255)/255)*100+.5)
    local bx1,by1,bw1,bh1=x+14*s,y+248*s,112*s,25*s
    local bx2=x+138*s
    rect(bx1,by1,bw1,bh1,card,6*s,255)
    self:_out(bx1,by1,bw1,bh1,6*s,1,border,210)
    local htw=measure(hex,13*s,"Verdana")
    textC(hex,bx1+(bw1-htw)*.5,by1+bh1*.5,textCol,13*s,"Verdana")
    rect(bx2,by1,bw1,bh1,card,6*s,255)
    self:_out(bx2,by1,bw1,bh1,6*s,1,border,210)
    local alphaText="Alpha "..tostring(ap).."%"
    local atw=measure(alphaText,13*s,"Verdana")
    textC(alphaText,bx2+(bw1-atw)*.5,by1+bh1*.5,dim,13*s,"Verdana")

    local function apply(kind)
        local h0,s0,v0=rgbToHsv92(arr[1],arr[2],arr[3])
        local q=copy(arr)
        if kind=="sv"then
            s0=clamp((Input.mx-isvx)/isvw,0,1)
            v0=1-clamp((Input.my-isvy)/isvh,0,1)
            q[1],q[2],q[3]=hsvToRgb92(h0,s0,v0)
        elseif kind=="h"then
            h0=clamp((Input.my-ihy)/ihh,0,1)
            q[1],q[2],q[3]=hsvToRgb92(h0,s0,v0)
        else
            q[4]=floor(clamp((Input.mx-gax)/gaw,0,1)*255+.5)
        end
        c:Set(q)
    end

    -- Entire popup shell is modal. Any click/right-click inside is consumed so
    -- nothing under the picker can be activated by the same pointer event.
    if Input.click and not self._consumed then
        if self:_hit(closeX-8*s,closeY-8*s,16*s,16*s)then
            self.colorPopup=nil
            self:_consume()
            return
        elseif self:_hit(isvx,isvy,isvw,isvh)then
            p.drag="sv";apply("sv");self:_consume()
        elseif self:_hit(ihx,ihy,ihw,ihh)then
            p.drag="h";apply("h");self:_consume()
        elseif self:_hit(gax,gay,gaw,gah)then
            p.drag="a";apply("a");self:_consume()
        elseif self:_hit(x,y,w,h)then
            self:_consume()
        end
    elseif Input.rightClick and not self._consumed and self:_hit(x,y,w,h)then
        self:_consume()
    end

    if p.drag then
        if Input.left then apply(p.drag)else p.drag=nil end
    end
end


-- Cleaner ESP preview ---------------------------------------------------------
function ESPPreview:SetEnabled(v)self.visible=v~=false;return self end
function ESPPreview:GetEnabled()return self.visible~=false end
function ESPPreview:SetSilhouette(v)self.showSilhouette=v~=false;return self end
function ESPPreview:GetSilhouette()return self.showSilhouette~=false end
function ESPPreview:SetStageGuides(v)self.stageGuides=v==true;return self end
function ESPPreview:GetStageGuides()return self.stageGuides==true end

local ultraESPFactory=Window.ESPPreview
function Window:ESPPreview(opt)
    opt=type(opt)=="table"and opt or{}
    local o=ultraESPFactory(self,opt)
    o.visible=opt.enabled~=false and opt.visible~=false
    o.showSilhouette=opt.silhouette~=false
    o.stageGuides=opt.stageGuides==true
    o.cleanStyle=opt.cleanStyle~=false
    if o.docked and o.tab then o.tab.dockedPreview=o end
    return o
end
Window.ESPWindow=Window.ESPPreview

function ESPPreview:_drawBody(x,y,w,h,docked)
    self:_syncBindings()
    local win=self.window
    local s=win and win.scale or 1
    self.order=self.order or{name=1,healthtext=2,distance=3}
    local seamless=docked and self.seamless~=false
    local headerH=seamless and 28*s or 40*s
    local pad=14*s

    if seamless then
        textC(upper(self.title or"ESP PREVIEW"),x+18*s,y+7*s,self:_theme("muted"),13*s,"Verdana")
        y=y+28*s;h=max(1,h-28*s);headerH=0
    else
        local frame=self:_theme("card")
        if win then win:_fill("overlay",x,y,w,h,"card",14*s)else rect(x,y,w,h,frame,14*s,frame[4]or 255)end
        if win then win:_out(x,y,w,h,14*s,.8,win.outlineColor or self:_theme("outline"),115)else outline(x,y,w,h,self:_theme("outline"),14*s,115,max(.8,s))end
        textC(upper(self.title or"ESP PREVIEW"),x+pad,y+20*s,self:_theme("muted"),13*s,"Verdana")
        line(x+pad,y+40*s,x+w-pad,y+40*s,self:_theme("line"),1,30)
    end

    local stageX=x+pad
    local stageY=y+headerH+pad
    local stageW=max(90,w-pad*2)
    local stageH=max(120,h-headerH-pad*2)
    if win then win:_fill("control",stageX,stageY,stageW,stageH,"control",12*s)else rect(stageX,stageY,stageW,stageH,self:_theme("control"),12*s,245)end
    outline(stageX,stageY,stageW,stageH,self:_theme("outline"),12*s,60,max(.8,s))

    if self.stageGuides then
        line(stageX+stageW*.5,stageY+12*s,stageX+stageW*.5,stageY+stageH-12*s,self:_theme("line"),1,16)
        line(stageX+12*s,stageY+stageH*.5,stageX+stageW-12*s,stageY+stageH*.5,self:_theme("line"),1,16)
    end

    if self.editable and self.widgetTools~=false then
        local labels={{"RESET",function()self:ResetLayout()end},{"MIX",function()self:ShuffleWidgets()end}}
        local bw,bh,g=48*s,21*s,5*s
        local total=#labels*bw+(#labels-1)*g
        local tx=stageX+stageW-total-8*s
        local ty=stageY+8*s
        for _,it in ipairs(labels)do
            local hov=self:_hitESP(Input.mx,Input.my,tx,ty,bw,bh)
            if hov then rect(tx,ty,bw,bh,self:_theme("controlHover"),6*s,220)end
            local tw=measure(it[1],9*s,"Verdana")
            textC(it[1],tx+(bw-tw)*.5,ty+bh*.5,self:_theme(hov and"text"or"muted"),9*s,"Verdana")
            if Input.click and hov and not E.pointerConsumed then it[2]();E.pointerConsumed=true;if win then win._consumed=true end end
            tx=tx+bw+g
        end
    end

    local humanW=min(stageW*.39,156*s)
    local humanH=min(stageH*.58,300*s)
    local bx=stageX+(stageW-humanW)*.5
    local by=stageY+(stageH-humanH)*.53
    local cx=bx+humanW*.5

    if self.showSilhouette~=false then
        local body=self:_theme("muted")
        local subtle={body[1],body[2],body[3],88}
        circle(cx,by+humanH*.10,humanW*.075,subtle,88)
        rect(cx-humanW*.10,by+humanH*.19,humanW*.20,humanH*.34,subtle,humanW*.07,88)
        line(cx-humanW*.08,by+humanH*.28,bx+humanW*.22,by+humanH*.48,subtle,5*s,88)
        line(cx+humanW*.08,by+humanH*.28,bx+humanW*.78,by+humanH*.48,subtle,5*s,88)
        line(cx-humanW*.06,by+humanH*.52,bx+humanW*.34,by+humanH*.88,subtle,5*s,88)
        line(cx+humanW*.06,by+humanH*.52,bx+humanW*.66,by+humanH*.88,subtle,5*s,88)
    end

    local boxCol=self.colors.box or self:_theme("white")
    if self.features.boxes~=false then
        -- cleaner corner-box instead of a heavy full rectangle
        local L=min(18*s,humanW*.18)
        local t=max(1,(self.boxThickness or 1)*s)
        line(bx,by,bx+L,by,boxCol,t);line(bx,by,bx,by+L,boxCol,t)
        line(bx+humanW-L,by,bx+humanW,by,boxCol,t);line(bx+humanW,by,bx+humanW,by+L,boxCol,t)
        line(bx,by+humanH-L,bx,by+humanH,boxCol,t);line(bx,by+humanH,bx+L,by+humanH,boxCol,t)
        line(bx+humanW,by+humanH-L,bx+humanW,by+humanH,boxCol,t);line(bx+humanW-L,by+humanH,bx+humanW,by+humanH,boxCol,t)
    end

    if self.features.skeleton then
        local sk=self.colors.skeleton or self:_theme("white")
        local hy=by+humanH*.12
        circle(cx,hy,humanW*.06,sk,210)
        line(cx,hy+humanW*.06,cx,by+humanH*.53,sk,1*s,210)
        line(cx,by+humanH*.30,bx+humanW*.25,by+humanH*.47,sk,1*s,210)
        line(cx,by+humanH*.30,bx+humanW*.75,by+humanH*.47,sk,1*s,210)
        line(cx,by+humanH*.53,bx+humanW*.34,by+humanH*.88,sk,1*s,210)
        line(cx,by+humanH*.53,bx+humanW*.66,by+humanH*.88,sk,1*s,210)
    end

    local health=self:_currentHealth()
    local hpCol=self.colors.health or{92,213,117,255}
    self.positions.healthbar=espSlot92(self.positions.healthbar or 4)
    local hits={}
    local function hit(kind,xx,yy,ww,hh)hits[#hits+1]={kind=kind,x=xx,y=yy,w=ww,h=hh}end
    local dragging=self._espDrag

    local function drawHealth(slot,ghost)
        local side=(slot==2 or slot==4 or slot==6 or slot==8)and slot or 4
        if side==4 or side==6 then
            local hx=side==4 and bx-10*s or bx+humanW+6*s
            rect(hx,by,4*s,humanH,{10,11,14,255},2*s,210)
            local fh=humanH*health/100
            rect(hx,by+humanH-fh,4*s,fh,hpCol,2*s,ghost and 150 or(hpCol[4]or 255))
            if not ghost then hit("healthbar",hx-8*s,by-5*s,20*s,humanH+10*s)end
        else
            local hy=side==2 and by-10*s or by+humanH+6*s
            rect(bx,hy,humanW,4*s,{10,11,14,255},2*s,210)
            rect(bx,hy,humanW*health/100,4*s,hpCol,2*s,ghost and 150 or(hpCol[4]or 255))
            if not ghost then hit("healthbar",bx-5*s,hy-8*s,humanW+10*s,20*s)end
        end
    end

    if self.features.healthbar~=false and(self.healthStyle=="bar"or self.healthStyle=="both"or self.healthStyle==nil)and dragging~="healthbar"then
        drawHealth(self.positions.healthbar,false)
    end

    local groups={}
    local function add(kind,textv,col)
        if kind=="healthtext"then
            if not(self.features.healthtext or self.healthStyle=="text"or self.healthStyle=="both")then return end
        elseif not self.features[kind]then return end
        local slot=espSlot92(self.positions[kind]or(kind=="distance"and 8 or(kind=="healthtext"and 6 or 2)))
        self.positions[kind]=slot
        groups[slot]=groups[slot]or{}
        groups[slot][#groups[slot]+1]={kind=kind,text=textv,col=col}
    end
    add("name",self.texts.name or"Player",self.colors.name or self:_theme("text"))
    add("healthtext",tostring(round(health)).." HP",hpCol)
    add("distance",self.texts.distance or"42m",self.colors.distance or self:_theme("muted"))

    for slot,list in pairs(groups)do
        sort(list,function(a,b)return(self.order[a.kind]or 99)<(self.order[b.kind]or 99)end)
        local ax,ay,row,col=slotInfo92(slot,bx,by,humanW,humanH,12*s)
        local lineH=18*s
        local shown={}
        local maxW=0
        for _,it in ipairs(list)do if it.kind~=dragging then shown[#shown+1]=it;maxW=max(maxW,measure(it.text,13*s,"Verdana"))end end
        local total=#shown*lineH
        local sx=col==1 and(ax-8*s-maxW)or(col==2 and(ax-maxW*.5)or ax+8*s)
        local sy=row==1 and(ay-8*s-total)or(row==2 and(ay-total*.5)or ay+8*s)
        for i,it in ipairs(shown)do
            local tw=measure(it.text,13*s,"Verdana")
            local tx=col==1 and(sx+maxW-tw)or(col==2 and(sx+(maxW-tw)*.5)or sx)
            local ty=sy+(i-1)*lineH
            text(it.text,tx,ty,it.col,13*s,"Verdana")
            hit(it.kind,tx-5*s,ty-4*s,tw+10*s,20*s)
        end
    end

    if self.features.snapline then line(stageX+stageW*.5,stageY+stageH,bx+humanW*.5,by+humanH,self.colors.snapline or self:_theme("accent"),1*s,180)end

    if self.editable and not self._espDrag and Input.click and not E.pointerConsumed then
        for i=#hits,1,-1 do
            local q=hits[i]
            if self:_hitESP(Input.mx,Input.my,q.x,q.y,q.w,q.h)then
                self._espDrag=q.kind
                self._espDragStarted=E.paintCount
                E.pointerConsumed=true
                if win then win._consumed=true end
                break
            end
        end
    end

    if self._espDrag then
        E.pointerConsumed=true;if win then win._consumed=true end
        local kind=self._espDrag
        local near=nearestSlot92(Input.mx,Input.my,bx,by,humanW,humanH,kind=="healthbar")
        local slots=kind=="healthbar"and{2,4,6,8}or{1,2,3,4,6,7,8,9}
        for _,slot in ipairs(slots)do
            local ax,ay=slotInfo92(slot,bx,by,humanW,humanH,12*s)
            local active=slot==near
            circle(ax,ay,(active and 3.8 or 2.2)*s,active and self:_theme("accent")or self:_theme("muted"),active and 255 or 120)
        end
        if kind=="healthbar"then
            drawHealth(near,true)
        else
            local label=kind=="name"and(self.texts.name or"Player")or(kind=="distance"and(self.texts.distance or"42m")or(tostring(round(health)).." HP"))
            local col=kind=="name"and(self.colors.name or self:_theme("text"))or(kind=="distance"and(self.colors.distance or self:_theme("muted"))or hpCol)
            local tw=measure(label,13*s,"Verdana")
            text(label,Input.mx-tw*.5,Input.my-7*s,col,13*s,"Verdana")
        end
        local started=self._espDragStarted or E.paintCount
        if E.paintCount>started and(Input.released or not Input.left)then
            espReorder92(self,kind,near,Input.my,bx,by,humanW,humanH)
            self.positions[kind]=near
            self._espDrag=nil
            self._espDragStarted=nil
        end
    end
end

-- Peak defaults are intentionally aggressive but do not remove features.
local ultraSetPerformanceMode=Fawn.SetPerformanceMode
function Fawn:SetPerformanceMode(mode)
    ultraSetPerformanceMode(self,mode)
    local P=self.Performance
    if P.Mode=="Peak"then
        P.SnowParticles=28
        P.ColorPickerCols=14;P.ColorPickerRows=10;P.ColorPickerHueSteps=24;P.ColorPickerAlphaSteps=48
        P.PeakStaticSurfaces=true
    elseif P.Mode=="Balanced"then
        P.SnowParticles=44
        P.ColorPickerCols=20;P.ColorPickerRows=14;P.ColorPickerHueSteps=32;P.ColorPickerAlphaSteps=64
        P.PeakStaticSurfaces=false
    else
        P.SnowParticles=64
        P.ColorPickerCols=32;P.ColorPickerRows=22;P.ColorPickerHueSteps=48;P.ColorPickerAlphaSteps=96
        P.PeakStaticSurfaces=false
    end
    return self
end

local ultraStats=Fawn.GetPerformanceStats
function Fawn:GetPerformanceStats()
    local q=ultraStats(self)
    q.colorPickerCells=(self.Performance.ColorPickerCols or 0)*(self.Performance.ColorPickerRows or 0)
    q.colorPickerHueSteps=self.Performance.ColorPickerHueSteps
    q.colorPickerAlphaSteps=self.Performance.ColorPickerAlphaSteps
    q.peakStaticSurfaces=self.Performance.PeakStaticSurfaces~=false
    q.reuseControlRects=self.Performance.ReuseControlRects~=false
    return q
end


-- ============================================================================
-- 10.0.1 three-dot accessory stack rewrite
-- Nested accessory children are owned by the three-dot popup itself instead of
-- borrowing the normal page dropdown/color popup state. This removes ordering
-- ambiguity and guarantees child-first modal input.
-- ============================================================================

local function accChildHit(win,ch)
    return ch and ch.x and ch.y and ch.w and ch.h and win:_hit(ch.x,ch.y,ch.w,ch.h)
end

local function accOpenChild(win,p,kind,c,x,y,w,h,tx,ty,tw,th)
    if not p or win.extraPopup~=p then return nil end
    local old=p.child
    if old and old.kind==kind and old.control==c then p.child=nil;return nil end
    local ch={kind=kind,control=c,x=x,y=y,w=w,h=h,triggerX=tx,triggerY=ty,triggerW=tw,triggerH=th,scroll=0}
    p.child=ch
    return ch
end

local function accDrawDropdown(win,parent,ch)
    local c=ch.control
    if not alive(c)then parent.child=nil;return end
    if c.optionsSource then c:RefreshOptionsSource(false)end
    local s=win.scale
    local F=REF.Full
    local rows=min(c:GetMaxVisibleOptions(),max(1,#c.options))
    ch.h=12*s+rows*F.itemH*s
    ch.w=max(96*s,ch.w or 148*s)
    ch.anchorY=ch.triggerY
    win:_clampPopup(ch)
    win:_popupFrame(ch)

    local maxScroll=max(0,#c.options-rows)
    ch.scroll=clamp(ch.scroll or 0,0,maxScroll)
    if win:_hit(ch.x,ch.y,ch.w,ch.h)and Input.wheel~=0 then ch.scroll=clamp(ch.scroll+Input.wheel*c:GetDropdownScrollStep(),0,maxScroll)end

    for row=1,rows do
        local i=row+ch.scroll
        if i>#c.options then break end
        local yy=ch.y+6*s+(row-1)*F.itemH*s
        local hov=win:_hit(ch.x+5*s,yy,ch.w-10*s,F.itemH*s)
        local selected=c.type=="dropdown"and c.value==i or(c.type=="multiselect"and c.value[i]==true)
        if hov then win:_fill("control",ch.x+5*s,yy,ch.w-10*s,F.itemH*s,"controlHover",F.itemR*s)
        elseif selected then rect(ch.x+5*s,yy,ch.w-10*s,F.itemH*s,win:_color("accent"),F.itemR*s,24)end
        textC(fit(c.options[i],ch.w-42*s,F.itemFont*s,"Verdana"),ch.x+F.itemPad*s,yy+F.itemH*s*.5,win:_color(selected and"white"or"text"),F.itemFont*s,"Verdana")
        if selected then ICON.check(ch.x+ch.w-20*s,yy+F.itemH*s*.5,12*s,win:_color("accent"))end
        if Input.click and not win._consumed and hov then
            if c.type=="dropdown"then c:Set(i);parent.child=nil else c:ToggleOption(i)end
            win:_consume()
            return
        end
    end
end

local function accDrawColor(win,parent,ch)
    local c=ch.control
    if not alive(c)then parent.child=nil;return end
    local s=win.scale
    ch.w=232*s;ch.h=238*s;ch.anchorY=ch.triggerY
    win:_clampPopup(ch);win:_popupFrame(ch)

    local arr=c.value
    local hue,sat,val=rgbToHsv92(arr[1],arr[2],arr[3])
    local svx,svy,svw,svh=ch.x+12*s,ch.y+39*s,158*s,108*s
    local hx,hy,hw,hh=ch.x+181*s,ch.y+39*s,16*s,108*s
    local ax,ay,aw,ah=ch.x+12*s,ch.y+169*s,185*s,12*s
    textC(upper(c.label or"COLOR"),ch.x+12*s,ch.y+17*s,win:_color("text"),13*s,"Verdana")

    local cols=max(8,floor(Fawn.Performance.ColorPickerCols or 14))
    local rows=max(6,floor(Fawn.Performance.ColorPickerRows or 10))
    local cw,chh=svw/cols,svh/rows
    for iy=0,rows-1 do
        local vv=1-iy/max(1,rows-1)
        for ix=0,cols-1 do
            local ss=ix/max(1,cols-1)
            local r,g,b=hsvToRgb92(hue,ss,vv)
            rect(svx+ix*cw,svy+iy*chh,cw+1,chh+1,{r,g,b,255},0,255)
        end
    end
    win:_out(svx-1*s,svy-1*s,svw+2*s,svh+2*s,4*s,.8,win:_color("outline"),210)
    local sx,sy=svx+sat*svw,svy+(1-val)*svh
    circle(sx,sy,3.2*s,win:_color("white"),255);outline(sx-4.2*s,sy-4.2*s,8.4*s,8.4*s,win:_color("black"),4.2*s,190,max(.8,s))

    local hs=max(12,floor(Fawn.Performance.ColorPickerHueSteps or 24))
    for i=0,hs-1 do
        local r,g,b=hsvToRgb92(i/max(1,hs-1),1,1)
        rect(hx,hy+i*(hh/hs),hw,hh/hs+1,{r,g,b,255},0,255)
    end
    win:_out(hx-1*s,hy-1*s,hw+2*s,hh+2*s,3*s,.8,win:_color("outline"),210)
    rect(hx-2*s,hy+hue*hh-1*s,hw+4*s,2*s,win:_color("white"),1*s,255)

    win:_fill("control",ax,ay,aw,ah,"control",4*s)
    local alphaSteps=max(16,floor(Fawn.Performance.ColorPickerAlphaSteps or 48))
    local seg=aw/alphaSteps
    for i=0,alphaSteps-1 do
        local aa=round(i/max(1,alphaSteps-1)*255)
        rect(ax+i*seg,ay,seg+1,ah,{arr[1],arr[2],arr[3],255},0,aa)
    end
    win:_out(ax,ay,aw,ah,4*s,.8,win:_color("outline"),210)
    rect(ax+(arr[4]or 255)/255*aw-1*s,ay-1*s,2*s,ah+2*s,win:_color("white"),1*s,255)

    local function apply(kind)
        local h0,s0,v0=rgbToHsv92(arr[1],arr[2],arr[3])
        local q=copy(arr)
        if kind=="sv"then s0=clamp((Input.mx-svx)/svw,0,1);v0=1-clamp((Input.my-svy)/svh,0,1);q[1],q[2],q[3]=hsvToRgb92(h0,s0,v0)
        elseif kind=="h"then h0=clamp((Input.my-hy)/hh,0,1);q[1],q[2],q[3]=hsvToRgb92(h0,s0,v0)
        else q[4]=round(clamp((Input.mx-ax)/aw,0,1)*255)end
        c:Set(q)
    end

    if Input.click and not win._consumed then
        if win:_hit(svx,svy,svw,svh)then ch.drag="sv";apply("sv");win:_consume()
        elseif win:_hit(hx,hy,hw,hh)then ch.drag="h";apply("h");win:_consume()
        elseif win:_hit(ax,ay,aw,ah)then ch.drag="a";apply("a");win:_consume()end
    end
    if ch.drag then if Input.left then apply(ch.drag)else ch.drag=nil end end
end

local function accDrawRow(win,parent,c,x,y,w,h,C,locked)
    local s=win.scale
    local left=x+C.padL*s
    local right=x+w-C.padR*s
    local cy=y+h*.5
    local labelW=max(30*s,w*.40)
    if c.type~="button"and c.type~="label"and c.type~="separator"then
        textC(fit(c.label or"",labelW,C.font*s,"Verdana"),left,cy,win:_color("text"),C.font*s,"Verdana")
    end

    if c.type=="dropdown"or c.type=="multiselect"then
        local fw=min(148*s,max(86*s,w*.48));local fh=C.ddH*s
        local fx,fy=right-fw,cy-fh*.5
        local hov=win:_hit(fx,fy,fw,fh)
        local ch=parent.child;local opened=ch and ch.control==c and ch.kind=="dropdown"
        win:_fill("control",fx,fy,fw,fh,(hov or opened)and"controlHover"or"control",C.ddR*s)
        local tv=c.type=="multiselect"and c:GetSummary()or tostring(c:Get()or"None")
        textC(fit(tv,fw-34*s,C.ddFont*s,"Verdana"),fx+C.ddPadL*s,cy,win:_color("text"),C.ddFont*s,"Verdana")
        chevDown(fx+fw-C.ddPadR*s-C.chev*s*.5,cy,C.chev*s,win:_color("chev"),opened)
        if (not locked or opened)and Input.click and not win._consumed and hov then
            accOpenChild(win,parent,"dropdown",c,fx,fy+fh+6*s,fw,0,fx,fy,fw,fh)
            win:_consume()
        end
        return
    end

    if c.type=="color"then
        local nominal=(C==REF.Compact)and REF.ColorChipCompact or REF.ColorChipFull
        local sz=min(C.sw,nominal)*s;local fx=right-sz;local fy=cy-sz*.5
        local ch=parent.child;local opened=ch and ch.control==c and ch.kind=="color"
        win:_fill("control",fx,fy,sz,sz,opened and"controlHover"or"control",min(8*s,sz*.24))
        rect(fx+1*s,fy+1*s,sz-2*s,sz-2*s,c.value,max(1,min(8*s,sz*.24)-1*s),c.value[4]or 255)
        win:_out(fx,fy,sz,sz,min(8*s,sz*.24),.9,win:_color("outline"),220)
        if (not locked or opened)and Input.click and not win._consumed and win:_hit(fx,fy,sz,sz)then
            accOpenChild(win,parent,"color",c,fx+sz-232*s,fy+sz+6*s,232*s,238*s,fx,fy,sz,sz)
            win:_consume()
        end
        return
    end

    if c.type=="slider"then
        local editing=win.sliderEdit and win.sliderEdit.control==c
        local display=win:_sliderDisplay(c,c.value or c.min)
        local shown=editing and tostring(win.sliderEdit.text or"")or display
        local txtW=measure(shown,C.valFont*s,"Verdana")
        local vw=max((editing and 78 or 58)*s,txtW+C.valPad*2*s)
        local vx=right-vw;local vh=C.valH*s;local vy=cy-vh*.5
        local sx=left+labelW;local sw=max(34*s,vx-C.sGap*s-sx)
        rect(sx,cy-2*s,sw,4*s,win:_color("control"),2*s,255)
        local q=clamp((clamp(c.value or c.min,c.min,c.max)-c.min)/max(.00001,c.max-c.min),0,1)
        rect(sx,cy-2*s,sw*q,4*s,win:_color("accent"),2*s,255);circle(sx+sw*q,cy,max(4*s,C.sKnob*s*.32),win:_color("white"),255)
        local vhv=win:_hit(vx,vy,vw,vh)
        win:_fill("control",vx,vy,vw,vh,(editing or vhv)and"controlHover"or"control",C.valR*s)
        if editing then win:_out(vx,vy,vw,vh,C.valR*s,1,win:_color("accent"),255);ultraSliderCaret(win,win.sliderEdit,shown,vx,vw,cy,C)
        else textC(display,vx+(vw-txtW)*.5,cy,win:_color("text"),C.valFont*s,"Verdana")end

        if c._accessoryDrag then
            if Input.left then c:Set(c.min+clamp((Input.mx-sx)/max(1,sw),0,1)*(c.max-c.min))else c._accessoryDrag=nil end
        end
        if not locked and not win._consumed then
            if (Input.click or Input.rightClick)and vhv then win:_startSliderEdit(c,{vx,vy,vw,vh});win:_consume()
            elseif Input.click and win:_hit(sx,cy-15*s,sw,30*s)and not editing then c._accessoryDrag=true;c:Set(c.min+clamp((Input.mx-sx)/max(1,sw),0,1)*(c.max-c.min));win:_consume()end
        end
        return
    end

    -- Reuse the stable renderer for remaining non-popup accessory controls.
    ultraAccessoryRow(win,c,x,y,w,h,C,not locked)
end

function Window:_drawExtraPopup()
    local p=self.extraPopup
    if not p then return end
    local owner=p.control
    if not alive(owner)then self.extraPopup=nil;return end
    local s=self.scale;local C=REF.Compact;local rowH=C.rowH*s;local header=36*s
    local controls=owner.extraSection and owner.extraSection.controls or{}
    local visible={}
    for _,c in ipairs(controls)do if alive(c)and visibilityPass(c)then visible[#visible+1]=c end end
    local keyRows=(owner.keybind and not owner.keybind.accessoryOnly)and 1 or 0
    p.w=REF.AccessoryWidth*s;p.h=header+max(1,keyRows+#visible)*rowH+8*s
    self:_clampPopup(p);self:_popupFrame(p)
    textC("ACCESSORIES",p.x+14*s,p.y+18*s,self:_color("muted"),12*s,"Verdana")

    local y=p.y+header
    local locked=p.child~=nil

    if keyRows==1 then
        local k=owner.keybind;local shown=self:_keyLabel(k)
        local tw=measure(shown,C.keyFont*s,"Verdana");local fw=min(126*s,max(76*s,tw+C.keyPad*2*s));local fh=C.keyH*s
        local fx=p.x+p.w-C.padR*s-fw;local fy=y+(rowH-fh)*.5;local cy=y+rowH*.5
        textC("Keybind",p.x+C.padL*s,cy,self:_color("text"),C.font*s,"Verdana")
        self:_fill("control",fx,fy,fw,fh,"control",C.keyR*s)
        textC(shown,fx+(fw-tw)*.5,cy,self:_color("text"),C.keyFont*s,"Verdana")
        y=y+rowH
    end

    for _,c in ipairs(visible)do
        local own=p.child and p.child.control==c
        accDrawRow(self,p,c,p.x,y,p.w,rowH,C,locked and not own)
        y=y+rowH
    end

    local ch=p.child
    if ch then
        if ch.kind=="dropdown"then accDrawDropdown(self,p,ch)
        elseif ch.kind=="color"then accDrawColor(self,p,ch)end
    end

    if p.child and(Input.click or Input.rightClick)and not self._consumed then
        local ch=p.child
        local inChild=accChildHit(self,ch)
        local inTrigger=ch.triggerX and self:_hit(ch.triggerX,ch.triggerY,ch.triggerW,ch.triggerH)
        if self:_hit(p.x,p.y,p.w,p.h)and not inChild and not inTrigger then p.child=nil;self:_consume()end
    elseif not p.child and(Input.click or Input.rightClick)and not self._consumed and self:_hit(p.x,p.y,p.w,p.h)then
        self:_consume()
    end
end

Fawn.Version="10.0.7-serotonin"
Fawn.APIRevision=47
Fawn.BuildId="fawn-modern-10.0.7-original-colorpicker-20260917"
Fawn.PolishVersion="10.0.7"
Fawn.DynamicCapabilities.AccessoryPopupStackV3=true
Fawn.DynamicCapabilities.ProtectedNativeDraw=true
Fawn.DynamicCapabilities.StrictDropdownChromeModal=true
Fawn.DynamicCapabilities.RawManagedImageDraw=true
Fawn.DynamicCapabilities.OriginalFawnColorPicker=true
Fawn.DynamicCapabilities.StrictColorPickerModal=true
Fawn.Runtime.AccessoryPopupFinal="dedicated child stack owned by three-dot popup; child-first modal input; original Fawn color picker; typed accessory sliders"
Fawn:SetPerformanceMode("Peak")

Fawn.DynamicCapabilities.PopupPointerIsolation=true
Fawn.DynamicCapabilities.AccessoryNumericEditor=true
Fawn.DynamicCapabilities.AccessoryColorPickerV2=true
Fawn.DynamicCapabilities.CleanOptionalESP=true
Fawn.DynamicCapabilities.NeutralManagedImages=true
Fawn.DynamicCapabilities.UltraPeakRenderer=true
Fawn.DynamicCapabilities.ReusedControlRects=true
Fawn.Runtime.AccessoryPopupFinal="exclusive popup-layer pointer routing; nested dropdown/color/key children; left/right-click numeric slider editor"
Fawn.Runtime.ESPPreview="clean corner-box preview; optional visibility; draggable slot widgets with stable release commit"
Fawn.Runtime.ManagedImages="raw 5-argument draw.Image first; neutral-white fallback only; no theme/glass tint path"
Fawn.Runtime.Performance="Peak: protected native drawing + static solid surfaces + authored-order Section traversal + reusable control rectangles + cached text/colors; original high-density color picker cost exists only while a picker is open"

end

return Fawn
