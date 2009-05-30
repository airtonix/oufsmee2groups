local raidFrame = oUF_Smee2_Groups.units.raid
local left,bottom,width,height

local extremes = {
   left         = nil,
   right        = nil,
   bottom       = nil,
   top          = nil,
}

for unit,frame in pairs(oUF.units)do
   
   if( unit:gmatch("raid")() == "raid" )then
      
      left,bottom,height,width = frame.Health:GetRect()
      
      if(extremes.left==nil or left < extremes.left )then
         extremes.left = left
      end
      if(extremes.bottom==nil or bottom < extremes.bottom )then
         extremes.bottom = bottom
      end
      if(extremes.top==nil or bottom+height > extremes.top )then
         extremes.top = bottom+height
      end
      if(extremes.right==nil or left+width > extremes.right)then
         extremes.right = left+width
      end
      
   end
   
end

raidFrame:SetWidth( extremes.right - raidFrame:GetLeft() )
raidFrame:SetHeight( extremes.top - raidFrame:GetBottom() )



































































