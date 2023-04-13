--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageHelpers 
import XMonad.Hooks.EwmhDesktops
import XMonad.Util.SpawnOnce
import XMonad.Util.Dzen
import XMonad.Util.Run
import XMonad.Actions.Volume
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Fullscreen
import System.Exit
import Graphics.X11.ExtraTypes.XF86

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.Monoid

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "alacritty"

-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--

myModMask       = mod1Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#000000"
myFocusedBorderColor = "#000000"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm, xK_Return), spawn (myTerminal))

    -- launch rofi
    , ((modm,               xK_d     ), spawn "rofi -show drun")

    -- Close focused window 
    , ((modm .|. shiftMask, xK_q     ), kill)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_c     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_c     ), restart "xmonad" True)
    
    -- Toggle fullscreen
    --, ((modm,               xK_f     ), sendMessage $ Toggle FULL)

    -- Shrink the master area
    , ((modm,               xK_j     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_semicolon     ), sendMessage Expand)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)
    -- Move focus to the next window

    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    --, ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    -- , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_semicolon     ), windows W.swapUp    )

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- toggle the status bar gap (used with avoidStruts from Hooks.ManageDocks)
    -- , ((modm , xK_b ), sendMessage ToggleStruts)
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = avoidStruts $ tiled ||| ThreeCol 1 (3/100) (5/9) ||| Mirror tiled ||| Full
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 5/9

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

-- Alert func displaying volume info.
alert :: Int -> X ()
alert vol = (dzenConfig centered . show . round . fromIntegral) vol where
    centered = onCurr (center 200 80)
        >=> font "-*-DejaVu Sans Mono-*-*-*-*-64-*-*-*-*-*-*-*"
        >=> addArgs ["-fg", "#ffffff"]
        >=> addArgs ["-bg", "#222222"]

-- Flags displaying current keyboard flag in xmobar.
flags :: IO String
flags = do
    lang <- fmap (take 2) (runProcessWithInput "sh" ["-c", "setxkbmap -query | grep layout | awk '{print $2}'"] "")
    let langFlag = case lang of
            "us" -> "🇺🇸"
            "ua" -> "🇺🇦"
            "ru" -> "ru"
            _    -> lang
    return langFlag

	--getFlag :: String -> String
	--getFlag lang =
	--  case lang of
	--    "us" -> "\xF0\x9F\x87\xBA\xF0\x9F\x87\xB8"
	--    "ua" -> "\xF0\x9F\x87\xBA\xF0\x9F\x87\xB3"
	--    "ru" -> "ru"
	--    _    -> lang
------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--

myManageHook :: ManageHook
myManageHook = composeAll
  [ isDialog                             --> doFloat
  , className =? "tor-browser"           --> doFloat
  , className =? "vlc"                   --> doFullFloat
  , appName =? "telegram-desktop" <&&> title =? "Media viewer" --> doFloat
  , isFullscreen                         --> doFullFloat
  , manageDocks
  ]

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--
myLogHook h = dynamicLogWithPP $ def
  { ppLayout = wrap "(<fc=#e4b63c>" "</fc>)"
  -- , ppSort = getSortByXineramaRule  -- Sort left/right screens on the left, non-empty workspaces after those
  --, ppTitleSanitize = const ""  -- Also about window's title
  , ppVisible = wrap "(" ")"  -- Non-focused (but still visible) screen
  , ppCurrent = xmobarColor "#000000" "" . wrap " [" "] "
  --, ppOrder = \(ws:l:t:ex) -> [ws, flagMonitor, l, t]
  --, ppCurrent = wrap "<fc=#b8473d>[</fc><fc=#7cac7a>" "</fc><fc=#b8473d>]</fc>"  -- Non-focused (but still visible) screen
  --, ppTitle = xmobarColor "#000000" "" . shorten 100
  , ppTitle = wrap "<fc=#ff0000>● </fc>" "" . shorten 100
  , ppOutput = hPutStrLn h
  }
------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.

myStartupHook :: X ()
myStartupHook = do
    spawnOnce "feh --bg-scale $HOME/Downloads/wallpaper2.jpg"
    spawnOnce "picom"
    spawn "setxkbmap -model pc105 -layout us,ua,ru -option grp:ctrl_shift_toggle"
    spawn "xinput set-prop 'Glorious Model O' 'libinput Accel Profile Enabled' 0, 1"
    spawn "xinput set-prop 'Glorious Model O' 'Coordinate Transformation Matrix' 0.5 0 0 0 0.5 0 0 0 1"
    spawn "xinput set-prop 'ELAN1300:00 04F3:3057 Touchpad' 'Coordinate Transformation Matrix' 0.9 0 0 0 0.9 0 0 0 1"

------------------------------------------------------------------------

main :: IO ()
main = do  
    xmobarProc <- spawnPipe "xmobar"
    xmonad $ ewmh $ docks $ defaults {
        logHook = myLogHook $ xmobarProc,
        startupHook = myStartupHook
    }
    where
        defaults = def {
            -- simple stuff
            terminal           = myTerminal,
            focusFollowsMouse  = myFocusFollowsMouse,
            borderWidth        = myBorderWidth,
            modMask            = myModMask,
            workspaces         = myWorkspaces,
            normalBorderColor  = myNormalBorderColor,
            focusedBorderColor = myFocusedBorderColor,
            
            -- hooks, layouts
            layoutHook         = myLayout,
            manageHook         = myManageHook <+> insertPosition Below Newer,
            
            -- key bindings
            mouseBindings      = myMouseBindings,
            keys = myKeys `mappend` \c -> M.fromList [ -- Volume control with notification
                ((0, xF86XK_AudioLowerVolume), lowerVolume 3 >>= (alert . round)),
                ((0, xF86XK_AudioRaiseVolume), raiseVolume 3 >>= (alert . round)),
                ((0, xF86XK_AudioMute       ), toggleMute >> return())
            ]
        }
