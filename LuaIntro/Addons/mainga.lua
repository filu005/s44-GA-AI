if addon.InGetInfo then
   return {
      name      = "MainGA";
      desc      = "Starter file of GA";
      author    = "filip";
      date      = "2016";
      license   = "GNU GPL, v2 or later";

      layer     = 0; --math.huge;
      hidden    = true; -- don't show in the widget selector
      api       = true; -- load before all others?
      before    = {"all"}; -- make it loaded before ALL other widgets (-> it must be the first widget that gets loaded!)

      enabled   = true; -- loaded by default?
   }
end

function addon.Initialize()
	local name = Game.modName
	Spring.Echo(("modName: %s"):format(name))
end

Spring.Echo("laduje MainGA")

-- function addon.MousePress(...)
-- 	--Spring.Echo(...)
-- end