CreatedByText db 'HUMAN CODED ASSEMBLY BY',0x0
KKJText db 'KRZYSZTOF KRYSTIAN JANKOWSKI',0x0
PMKCText db 'POZNANSKIE MUZEUM KULTURY CYFROWEJ', 0x0
PressEnterText db 'PRESS ENTER', 0x0
MainMenuCopyText db '(MIT) 2026 P1X',0x0
QuitText db 'Thanks for playing!',0x0D,0x0A,'Visit http://smol.p1x.in/assembly for more...', 0x0D, 0x0A, 0x0
VerText db 'BUILD VERSION: ',0x0

Fontset1Text db ' !',34,'#$%&',39,'()*+,-./:;<=>?',0x0
Fontset2Text db '@ 0123456789',0x0
Fontset3Text db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',0x0


; =========================================== HELP SCREENS ==================|80

HelpFooter1Text db '> PRESS ENTER FOR NEXT PAGE',0x0
HelpFooter2Text db '< PRESS ESC TO BACK TO MAIN MENU',0x0

HelpPage0Text:
db 'CORTEX LABS - QUICK HELP!',0x0
db ' ',0x0
db '-------------------------------------',0x0
db 'FOR FULL MANUAL CHECK @ FLOPPY IN DOS',0x0
db 'READ > MANUAL.TXT < FILE',0x0
db '-------------------------------------',0x0
db ' ',0x0
db 'TABLE OF CONTENT',0x0
db '- GAME IDEA',0x0
db '- BASE EXPANSION & BUILDINGS',0x0
db '- RAILS MANAGEMENT',0x0
db '- RESOURCES & UPGRADES',0x0
db '- PAGE 5',0x0
db '- PAGE 6',0x0
db '- PAGE 7',0x0
db 0x00

HelpPage1Text:
db 'GAME IDEA',0x0
db ' ',0x0
db 'CORTEX LABS IS A STRATEGY PUZZLE GAME.',0x00
db 'YOUR MISSION IS TO EXTRACT, REFINE,',0x0
db 'AND RETURN RESOURCES ON OTHER PLANET.',0x0
db '-------------------------------------',0x0
db 0x00

HelpPage2Text:
db 'BASE EXPANSION & BUILDINGS',0x0
db ' ',0x0
db 'PAGE 2 OF 7',0x0
db 0x00

HelpPage3Text:
db 'RAILS MANAGEMENT',0x0
db ' ',0x0
db 'PAGE 3 OF 7',0x0
db 0x00

HelpPage4Text:
db 'RESOURCES & UPGRADES',0x0
db ' ',0x0
db 'PAGE 4 OF 7',0x0
db 0x00

HelpPage5Text:
db 'PAGE 5',0x0
db ' ',0x0
db 'PAGE 5 OF 7',0x0
db 0x00
HelpPage6Text:
db 'PAGE 6',0x0
db ' ',0x0
db 'PAGE 6 OF 7',0x0
db 0x00
HelpPage7Text:
db 'PAGE 7',0x0
db ' ',0x0
db 'PAGE 7 OF 7',0x0
db 0x00

HelpArrayText:
dw HelpPage0Text
dw HelpPage1Text
dw HelpPage2Text
dw HelpPage3Text
dw HelpPage4Text
dw HelpPage5Text
dw HelpPage6Text
dw HelpPage7Text

; =========================================== WINDOWS DEFINITIONS ===========|80

WindowMainMenuText          db 'MAIN MANU',0x0
MainMenuSelectionArrayText:
db '> NEW GAME',0x0
db '# PREVIEW TILESETS',0x0
db '? QUICK HELP',0x0
db '< QUIT',0x0
db 0x00

WindowBaseBuildingsText     db 'BASE BUILDING',0x0
WindowBaseSelectionArrayText:
db '< CLOSE WINDOW',0x0
db '> EXPAND BASE',0x0
db '+ BUILD COLECTOR',0x0
db '+ BUILD POD FACTORY',0x0
db '+ BUILD SILOS',0x0
db '+ BUILD RAFINERY',0x0
db '+ BUIILD LABORATORY',0x0
db '+ BUIILD ANTENNA',0x0
db 0x00

WindowRemoteBuildingsText   db 'REMOTE BUILDINGS',0x0
WindowRemoteSelectionArrayText:
db '< CLOSE WINDOW',0x0
db 'ROTATE EXIT TARGET:',0x0
db '+ BUILD EXTRACTOR',0x0
db '+ BUILD ANTENNA',0x0
db 0x00

WindowStationText           db 'STATION',0x0
WindowStationSelectionArrayText:
db '< CLOSE WINDOW',0x0
db '+ BUILD STATION',0x0
db 0x00

WindowMinimapText           db 'SATELITE IMAGE',0x0
WindowBriefingText           db 'BRIEFING',0x0
WindowBriefingSelectionArrayText:
db '> START MISSION',0x0
db '* RANDOMIZE TERRAIN',0x0
db '< REJECT',0x0
db 0x00


WindowPODsText              db 'PODS MANUFACTURE',0x0
WindowPODsSelectionArrayText:
db '< CLOSE WINDOW',0x0
db 'ROTATE EXIT TARGET:',0x0
db '+ BUILD STATION',0x0
db '* DEPLOY NEW POD',0x0
db 0x00

WindowExtractorText              db 'EXTRACTOR SETUP',0x0
WindowExtractorSelectionArrayText:
db '< CLOSE WINDOW',0x0
db '> EXTRACT: WHITE',0x00
db '> EXTRACT: GREEN',0x00
db '> EXTRACT: BLUE',0x00
db 0x00

WindowAntennaText              db 'MAP VIEW',0x0
WindowExtractInfoText              db 'EXTRACTION PROCESS',0x0
WindowExtractInfoSelectionArrayText:
db '< CLOSE WINDOW',0x0
db '! STOP EXTRACTION',0x0
db 0x00

WindowResourceInfoText              db 'RESOURCE INFORMATION',0x0
WindowAntennaSelectionArrayText:
WindowResourceInfoSelectionArrayText:
db '< OK',0x0
db 0x00

ExtractedText db 'EXTRACTED: ',0x0
ResourceTitle db 'RESOURCE DETAILS',0x0
ResourceInfoLine1 db 'THIS IS A RESOURCE',0x0
ResourceAmountText db 'AMOUNT: ',0x0
