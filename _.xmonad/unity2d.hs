{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses, TypeSynonymInstances, FlexibleContexts, NoMonomorphismRestriction #-}

-- XMonad config for Gnome on Ubuntu 12.10 by Cody P Schafer <xmonad@codyps.com>
-- Based on "XMonad configuration file by Thomas ten Cate <ttencate@gmail.com>"
--
-- Works on xmonad-0.8, NOT on 0.7 or below; and of course
-- xmonad-contrib needs to be installed as well
--
-- I use this on Ubuntu 12.10 configured as a window manager for gnome (or is
-- it unity2d? or gnome-fallback?).
--
-- All workspaces except F9 respect panels and docks.
-- F9 is the fullscreen workspace (for mplayer, etc.).
-- F10 is the instant messaging workspace.
--
-- Pidgin and Skype windows are automatically placed onto the IM workspace.
-- Their contact lists each get a column on the right side of the screen,
-- and all their other windows (chat windows, etc.) go into a grid layout
-- in the remaining space.
-- (This uses a copied and modified version of XMonad.Layout.IM.)
--
-- Navigation:
-- Win+F1..F10          switch to workspace
-- Win+Up/Down          switch to previous/next workspace
-- Win+Tab              focus next window
-- Win+Shift+Tab        focus previous window
--
-- Screen Managment:
-- Win+x		swap workspaces between screens
-- Win+[Left,Right]	move focus to prev/next screen
--
-- Window management:
-- Win+z		      switch to previous WS.
-- Win+[F1..F10]	      move focus to workspace
-- Win+Shift+F1..F10          move window to workspace
-- Win+Ctrl+[F1..F10]	      swap current workspace with another workspace
-- Win+Shift+Up/Down	      move focused window to prev/next WS and follow it.
-- Win+Shift+C                close window
-- Win+ScrollUp/Down    move focused window up/down
-- Win+M                move window to master area
-- Win+N                refresh the current window
-- Win+LMB              move floating window
-- Win+RMB              resize floating window
-- Win+MMB              unfloat floating window
-- Win+T                unfloat floating window
--
-- Layout management:
-- Win+Ctrl+Left/Right       shrink/expand master area
-- Win+,/.             move more/less windows into master area
-- Win+Space            cycle layouts
--
-- Other:
-- Win+Enter            start a terminal
-- Win+[R,D]            open the Gnome run dialog
-- Win+Q                restart XMonad
-- Win+Shift+E          display Gnome shutdown dialog

import XMonad
import XMonad.Util.EZConfig
import qualified XMonad.StackSet as S
import XMonad.Actions.CycleWS
import XMonad.Config.Gnome
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Combo
import XMonad.Layout.Grid
import XMonad.Layout.Tabbed
import XMonad.Layout.Accordion
import XMonad.Layout.Column
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.TwoPane
import XMonad.Layout.WindowNavigation
import XMonad.Layout.Gaps
import XMonad.Util.WindowProperties
import Control.Monad
import Data.Ratio
import XMonad.Actions.CycleWS
import XMonad.Actions.SwapWorkspaces
import XMonad.Hooks.ManageHelpers
import qualified Data.Map as M
import XMonad.Hooks.SetWMName
import Data.Monoid          (Endo(..))
import XMonad.Hooks.EwmhDesktops

-- defaults on which we build
-- use e.g. defaultConfig or gnomeConfig
myBaseConfig = ewmh gnomeConfig

-- display
-- replace the bright red border with a more stylish colour
myBorderWidth = 2
myNormalBorderColor = "#202030"
myFocusedBorderColor = "#A0A0D0"

-- workspaces
myWorkspaces = ["web", "mail", "editor"] ++ (miscs 5) ++ ["fullscreen", "im"]
	where miscs = map (("misc" ++) . show) . (flip take) [1..]
isFullscreen = (== "fullscreen")

-- layouts
basicLayout = Tall nmaster delta ratio where
	nmaster = 1
	delta   = 3/100
	ratio   = 1/2
tallLayout = named "tall" $ avoidStruts $ basicLayout
wideLayout = named "wide" $ avoidStruts $ Mirror basicLayout
singleLayout = named "single" $ avoidStruts $ noBorders Full
fullscreenLayout = named "fullscreen" $ noBorders Full
imLayout = avoidStruts $ reflectHoriz $ withIMs ratio rosters chatLayout where
	chatLayout      = Grid
	ratio           = 1%6
	rosters         = [skypeRoster, pidginRoster]
	pidginRoster    = And (ClassName "Pidgin") (Role "buddy_list")
	skypeRoster     = (ClassName "Skype") `And` (Not (Title "Options")) `And` (Not (Role "Chats")) `And` (Not (Role "CallWindowForm"))

-- myLayoutHook = gaps [(U, 24)] $ fullscreen $ im $ normal where
myLayoutHook = smartBorders ( fullscreen $ im $ normal ) where
	normal     = smartBorders (tallLayout ||| wideLayout
		 ||| singleLayout ||| simpleTabbed ||| Grid)
	fullscreen = onWorkspace "fullscreen" fullscreenLayout
	im         = onWorkspace "im" imLayout

-- Note: often xprop will display 2 class names. So far, I have found that
-- using the 2nd one/one with capitals has worked, while the first one/all
-- lowercase does not.
unityManageHooks = composeAll [
	  className =? "Unity-2d-panel"    --> doIgnore
	, className =? "Unity-2d-launcher" --> doIgnore
	-- Run Dialog.
	, className =? "Gnome-panel"       --> doFloat
	-- doesn't resize properly.
	, className =? "Bluetooth-wizard"  --> doFloat
	-- Is intendend to be a popup dialog, but lacks a controlling window.
	, className =? "Apport-gtk"        --> doCenterFloat
	-- Flash
	, className =? "Plugin-container"  --> doFloat
	-- Pops up when a drive is inserted
	, className =? "Gnome-fallback-mount-helper" --> doCenterFloat
	]

-- doRemoveBorders :: Query (Endo WindowSet)
-- doRemoveBorders = ask >>= \w -> liftX . withDisplay $ \d -> io $ setWindowBorder d w 0

looManageHooks = composeAll [
		--className =? "Soffice" <&&> stringProperty "WM_WINDOW_ROLE" =? "dialog" -->
		--	doCenterFloat

		-- http://code.google.com/p/xmonad/issues/detail?id=200
		-- workaround presenter settings window flickering in tight loop.
		--, className =? "Soffice" <&&> stringProperty "WM_WINDOW_ROLE" =? "dialog" -->
		--	doRemoveBorders
	]

webManageHooks = composeAll [isWeb --> moveToWeb] where
	isWeb = className =? "Firefox"
	moveToWeb = doF $ S.shift "web"

-- put the Pidgin and Skype windows in the im workspace
imManageHooks = composeAll [isIM --> moveToIM] where
	isIM     = foldr1 (<||>) [isPidgin, isSkype]
	isPidgin = className =? "Pidgin"
	isSkype  = className =? "Skype"
	moveToIM = doF $ S.shift "im"

myManageHook = imManageHooks
	<+> manageHook myBaseConfig
	<+> unityManageHooks
	<+> webManageHooks
	<+> looManageHooks

-- Mod4 is the Super / Windows key
myModMask = mod4Mask
altMask = mod1Mask

modm = myModMask
-- better keybindings for dvorak
myKeys conf = M.fromList $
    [ ((myModMask .|. shiftMask  , xK_Return), spawn $ XMonad.terminal conf)
    , ((myModMask                , xK_r     ), spawn "gnome-panel-control --run-dialog")
    , ((myModMask .|. shiftMask  , xK_c     ), kill)
    , ((myModMask                , xK_space ), sendMessage NextLayout)
    , ((myModMask                , xK_n     ), refresh)
    , ((myModMask                , xK_Return), windows S.swapMaster)
    , ((myModMask                , xK_Tab   ), windows S.focusDown)
    , ((myModMask .|. shiftMask  , xK_Tab   ), windows S.focusUp)
    , ((myModMask                , xK_Down  ), windows S.swapDown)
    , ((myModMask                , xK_Up    ), windows S.swapUp)
    , ((myModMask                , xK_m     ), windows S.focusMaster)
    , ((myModMask              , xK_comma ), sendMessage (IncMasterN 1))
    , ((myModMask              , xK_period), sendMessage (IncMasterN (-1)))
    , ((myModMask .|. controlMask, xK_Left  ), sendMessage Shrink)
    , ((myModMask .|. controlMask, xK_Right ), sendMessage Expand)
    , ((myModMask                , xK_t     ), withFocused $ windows . S.sink)
    , ((myModMask                , xK_q     ), broadcastMessage ReleaseResources >> restart "xmonad" True)
    , ((myModMask .|. shiftMask  , xK_e     ), spawn "gnome-session-save --kill")
    ] ++
    -- Alt+F1..F10 switches to workspace
    -- (Alt is in a nicer location for the thumb than the Windows key,
    -- and 1..9 keys are already in use by Firefox, irssi, ...)
    -- [ ((myModMask, k), windows $ S.greedyView i)
    --    | (i, k) <- zip (XMonad.workspaces conf) workspaceKeys
    -- ] ++
    -- mod+F1..F10 moves window to workspace and switches to that workspace
    --[ ((myModMask .|.  shiftMask , k), (windows $ S.shift i) >> (windows $ S.greedyView i))
    --    | (i, k) <- zip (XMonad.workspaces conf) workspaceKeys
    --]

    -- mod-F[1..12], Switch to workspace N
    -- mod-shift-F[1..12], Move client to workspace N
    -- mod-ctrl-F[1..12], swap current workspace with workspace N.
    [((m .|. myModMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) workspaceKeys
        , (f, m) <- [(S.greedyView, 0), (S.shift, shiftMask), (swapWithCurrent, controlMask)]]
    ++

    -- -- Old mod-ctrl-F[1..12] code.
    -- [((modm .|. controlMask, k), windows $ swapWithCurrent i)
    --    | (i, k) <- zip (XMonad.workspaces conf) workspaceKeys]
    -- ++

    -- mod-[e,w], do something funky with views/screens.
    [((m .|. myModMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e] [0..]
        , (f, m) <- [(S.view, 0), (S.shift, shiftMask)]]

    ++

    [
      ((modm,               xK_Down),  nextWS)
    , ((modm,               xK_Up),    prevWS)
    , ((modm .|. shiftMask, xK_Down),  shiftToNext >> nextWS)
    , ((modm .|. shiftMask, xK_Up),    shiftToPrev >> prevWS)
    , ((modm,               xK_Right), nextScreen)
    , ((modm,               xK_Left),  prevScreen)
    , ((modm .|. shiftMask, xK_Right), shiftNextScreen >> nextScreen)
    , ((modm .|. shiftMask, xK_Left),  shiftPrevScreen >> prevScreen)
    , ((modm,               xK_z),     toggleWS)
    , ((modm,               xK_x),     swapNextScreen)
    ]

    where workspaceKeys = [xK_F1 .. xK_F12]

-- mouse bindings that mimic Gnome's
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))
    , ((modMask, button2), (\w -> focus w >> (withFocused $ windows . S.sink)))
    , ((modMask, button4), (const $ windows S.swapUp))
    , ((modMask, button5), (const $ windows S.swapDown))
    ]

-- put it all together
main = xmonad $ myBaseConfig
	{ modMask = myModMask
	, workspaces = myWorkspaces
	, layoutHook = myLayoutHook
	, manageHook = myManageHook
	, borderWidth = myBorderWidth
	, normalBorderColor = myNormalBorderColor
	, focusedBorderColor = myFocusedBorderColor
	, keys = myKeys
	, mouseBindings = myMouseBindings
	, startupHook = setWMName "LG3D" -- workaround JAVA being a POS.
	}
 
-- modified version of XMonad.Layout.IM --
 
-- | Data type for LayoutModifier which converts given layout to IM-layout
-- (with dedicated space for the roster and original layout for chat windows)
data AddRosters a = AddRosters Rational [Property] deriving (Read, Show)
 
instance LayoutModifier AddRosters Window where
  modifyLayout (AddRosters ratio props) = applyIMs ratio props
  modifierDescription _                = "IMs"
 
-- | Modifier which converts given layout to IMs-layout (with dedicated
-- space for rosters and original layout for chat windows)
withIMs :: LayoutClass l a => Rational -> [Property] -> l a -> ModifiedLayout AddRosters l a
withIMs ratio props = ModifiedLayout $ AddRosters ratio props
 
-- | IM layout modifier applied to the Grid layout
gridIMs :: Rational -> [Property] -> ModifiedLayout AddRosters Grid a
gridIMs ratio props = withIMs ratio props Grid
 
hasAnyProperty :: [Property] -> Window -> X Bool
hasAnyProperty [] _ = return False
hasAnyProperty (p:ps) w = do
    b <- hasProperty p w
    if b then return True else hasAnyProperty ps w
 
-- | Internal function for placing the rosters specified by
-- the properties and running original layout for all chat windows
applyIMs :: (LayoutClass l Window) =>
               Rational
            -> [Property]
            -> S.Workspace WorkspaceId (l Window) Window
            -> Rectangle
            -> X ([(Window, Rectangle)], Maybe (l Window))
applyIMs ratio props wksp rect = do
    let stack = S.stack wksp
    let ws = S.integrate' $ stack
    rosters <- filterM (hasAnyProperty props) ws
    let n = fromIntegral $ length rosters
    let (rostersRect, chatsRect) = splitHorizontallyBy (n * ratio) rect
    let rosterRects = splitHorizontally n rostersRect
    let filteredStack = stack >>= S.filter (`notElem` rosters)
    (a,b) <- runLayout (wksp {S.stack = filteredStack}) chatsRect
    return (zip rosters rosterRects ++ a, b)
