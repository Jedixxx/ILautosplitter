state("Backrooms-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
    vars.Uhara.AlertLoadless();
    //vars.Uhara.EnableDebug();

    settings.Add("hub_auto_reset", true, "The Hub mode automatic reset");
    settings.Add("level0_splits", false, "[Level 0 IL Splits] Splits on first log, restart and pitfall enter (Solo Any%)");
    settings.Add("carcodes_splits", false, "[Car Codes IL Splits] Splits on leaving codepad and elevator activation (Solo Any%)");
    settings.Add("elevrooms_splits", false, "[Elev Rooms IL Splits] Splits on door opens (Solo Any%)");
    settings.Add("office_splits", false, "[Office IL Splits] Splits on vending door enter and jump room door open (Solo Any%)");
    settings.Add("mainhall_splits", false, "[Main Hall IL Splits] Splits on puzzle finish and OOB clip 1 and 2 (Solo Any%)");
    settings.Add("rfyl_splits", false, "[RFYL IL Splits] Splits on Sliding Bed 1 and Sliding Bed 2 (Solo Any%)");
    settings.Add("fow_splits", false, "[FOW IL Splits] Splits on Restart and Second Juice Pickup (Solo Any%)");
    settings.Add("snackrooms_splits", false, "[Snackrooms IL Splits] Splits on typewriter enter and finish (Solo Any%)");
    settings.Add("hotelchase_splits", false, "[Hotel Chase IL Splits] Splits on lever pull and chainsaw door open (Solo Any%)");
    settings.Add("grassroom_splits", false, "[Grassrooms IL Splits] Splits on rope pickup and rope interact in grassrooms (Solo Any%)");

    vars.HasStarted = false;
    vars.HasExited = false;
}

init
{
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
    vars.Resolver.Watch<ulong>("LoadingStart", vars.Events.FunctionFlag("WB_LoadingScreen_C", "WB_LoadingScreen_C", "PreConstruct"));
    vars.Resolver.Watch<ulong>("LoadingFinish", vars.Events.FunctionFlag("MP_PlayerController_C", "MP_PlayerController_C", "ClientGotoState"));
    vars.Resolver.Watch<ulong>("LoadingEnding", vars.Events.FunctionFlag("", "", "ExecuteUbergraph_BP_ExitZone_GameEnding"));
    vars.Resolver.Watch<ulong>("RestartLevel", vars.Events.FunctionFlag("WB_Button_RestartGame_C", "WB_Button_RestartGame_C", "BndEvt__WB_Button_Close_Button_K2Node_ComponentBoundEvent_0_OnButtonClickedEvent__DelegateSignature"));
    vars.Resolver.Watch<byte>("IsInHubGM", vars.Events.FunctionParentPtr("BP_MyGameInstance_C", "BP_MyGameInstance_C", "CheckAchievementQueue"), 0x350);
    vars.Resolver.Watch<ulong>("Death", vars.Events.FunctionFlag("GameEnd_UI_2_C", "GameEnd_UI_2_C", "PreConstruct"));
    vars.Resolver.Watch<ulong>("ContinueButton", vars.Events.FunctionFlag("UI_Menu_Evaluation_C", "UI_Menu_Evaluation_C", "BndEvt__UI_Menu_Evaluation_UI_Menu_Button_K2Node_ComponentBoundEvent_1_OnClick__DelegateSignature"));
    vars.Resolver.Watch<ulong>("MainMenu", vars.Events.FunctionFlag("CheatManager", "CheatManager", "ReceiveInitCheatManager"));

    vars.WasEnding = false;
    vars.LoadingState = true;

    // IL Events

    // General
    vars.Resolver.Watch<ulong>("JuicePickup", vars.Events.FunctionFlag("BP_Juice_C", "BP_Juice_C", "ReceiveBeginPlay")); 
    vars.Resolver.Watch<ulong>("CapsuleTouch", vars.Events.FunctionFlag("FancyMovementComponent", "CharMoveComp", "CapsuleTouched"));    
    vars.ilStage = 0;
    
    // Level 0
    vars.Resolver.Watch<ulong>("FirstLadderPieceUsed", vars.Events.FunctionFlag("BP_LadderPiece_C", "BP_LadderPiece", "OnActorUsed"));  
    vars.Resolver.Watch<ulong>("Level0Load", vars.Events.FunctionFlag("MP_Level0_C", "MP_Level0_C", "UserConstructionScript"));  
    vars.Resolver.Watch<ulong>("EnterPitfalls", vars.Events.FunctionFlag("BPCharacter_Demo_C", "BPCharacter_Demo_C", "BalanceTimeline__UpdateFunc"));  
    
    // Car Codes
    vars.Resolver.Watch<ulong>("LeaveColorPicker", vars.Events.FunctionFlag("BP_ColorPicker_C", "BP_ColorPicker", "OnUnPossess"));  
    vars.Resolver.Watch<ulong>("CarCodesElevatorButtonClick", vars.Events.FunctionFlag("BP_Elevator_Box_C", "BP_Elevator_Box", "Close__UpdateFunc"));  

    // Elevator Rooms
    vars.Resolver.Watch<ulong>("L2FirstDoorOpen", vars.Events.FunctionFlag("BP_SingleDoor_C", "StaticMeshActor_612_LOD2", "OnActorUsed"));  
    vars.Resolver.Watch<ulong>("L2ElevDoorOpen", vars.Events.FunctionFlag("BP_SingleDoor_C", "StaticMeshActor_506_LOD2", "OnActorUsed"));    

    // Office
    vars.Resolver.Watch<ulong>("OfficeLoad", vars.Events.FunctionFlag("MP_Office_C", "MP_Office_C", "ReceiveBeginPlay"));  
    vars.Resolver.Watch<ulong>("VendingDoorOpen", vars.Events.FunctionFlag("BP_VendingDoor_C", "BP_Door71", "Timeline_0__FinishedFunc"));
    vars.Resolver.Watch<ulong>("OfficeSkipDoorOpen", vars.Events.FunctionFlag("BP_OfficeDoor_C", "BP_Door24", "OnActorUsed"));

    vars.WasVendingDoorOpened = false;
    
    // Main Hall
    vars.Resolver.Watch<ulong>("PicturePuzzleFinished", vars.Events.FunctionFlag("BP_LobbyDoors_C", "BP_LobbyDoors", "Timeline_0__UpdateFunc"));
    
    vars.WasPicturePuzzleDone = false;

    // RFYL
    vars.Resolver.Watch<ulong>("SlideBed1", vars.Events.FunctionFlag("BP_Slide_C", "BP_Slide", "Roll__UpdateFunc"));
    vars.Resolver.Watch<ulong>("SlideBed2", vars.Events.FunctionFlag("BP_Slide_C", "BP_Slide2", "Roll__UpdateFunc"));
    
    // FOW
    vars.Resolver.Watch<ulong>("Level10Load", vars.Events.FunctionFlag("MP_Level10_C", "MP_Level10_C", "ReadyToStartMatch")); 

    // Snackrooms
    vars.Resolver.Watch<ulong>("TypeWriterClick", vars.Events.FunctionFlag("BP_TypeWriter_C", "BP_TypeWriter", "OnActorUsed"));
    vars.Resolver.Watch<ulong>("TypeWriterCompleted", vars.Events.FunctionFlag("BP_Snackrooms_Exit_C", "BP_Snackrooms_Exit", "Swing__UpdateFunc"));

    // Hotel Chase
    vars.Resolver.Watch<ulong>("DashLeverUsed", vars.Events.FunctionFlag("BP_Dash_Lever_C", "BP_Dash_Lever", "OnActorUsed"));
    vars.Resolver.Watch<ulong>("DashChainsawDoorOpened", vars.Events.FunctionFlag("BP_Plank_Door_C", "BP_Plank_Door", "OnActorUsed"));   

    // Grassrooms
    vars.Resolver.Watch<ulong>("RopePickup", vars.Events.FunctionFlag("BP_Rope_C", "BP_Rope_C", "ReceiveBeginPlay"));
    vars.Resolver.Watch<ulong>("UseRope", vars.Events.FunctionFlag("BP_RopeZone_C", "BP_RopeZone_C", "OnActorUsed"));
}

start
{
    if (!vars.LoadingState && !vars.HasStarted) {
        vars.HasStarted = true;
        return true;
    }
}

update
{
    vars.Uhara.Update();

    if ((old.LoadingStart != current.LoadingStart) || (old.MainMenu != current.MainMenu) || (old.LoadingEnding != current.LoadingEnding)) {
        vars.LoadingState = true;
        vars.ilStage = 0; 
    }
    if (old.RestartLevel != current.RestartLevel) {
        vars.LoadingState = true;
        vars.WasEnding = false;
    }
    if (old.MainMenu != current.MainMenu) vars.HasExited = true;
    if ((old.LoadingFinish != current.LoadingFinish) && vars.LoadingState) {
        vars.LoadingState = false;
        vars.HasExited = false;
        vars.WasVendingDoorOpened = false;
        vars.WasPicturePuzzleDone = false;   
    }

    // IL Updates

    // Office
    if (old.VendingDoorOpen != current.VendingDoorOpen) vars.WasVendingDoorOpened = true;
}

split
{
    if ((old.LoadingStart != current.LoadingStart) && !vars.HasExited) {
        if (vars.WasEnding) {
            vars.WasEnding = false;
            return false;
        }
        return true;
    }
    if (old.LoadingEnding != current.LoadingEnding) {
        vars.WasEnding = true;
        return true;
    }

    // IL Splits
    
    // Level 0
    if ((vars.ilStage == 0) && (old.FirstLadderPieceUsed != current.FirstLadderPieceUsed)){
        vars.ilStage++;
	return true;
    }
    if ((vars.ilStage == 1) && (old.Level0Load != current.Level0Load)){
        vars.ilStage++;
	return true;
    }
    if ((vars.ilStage == 2) && (old.EnterPitfalls != current.EnterPitfalls)) {
	vars.ilStage = -1;
	return true;
    }

    // Car Codes
    if ((vars.ilStage == 0) && (old.LeaveColorPicker != current.LeaveColorPicker)){
        vars.ilStage++;
	return true;
    }
    if ((vars.ilStage == 1) && (old.CarCodesElevatorButtonClick != current.CarCodesElevatorButtonClick)) {
	vars.ilStage = -1;
	return true;
    }

    // Elevator Rooms
    if ((vars.ilStage == 0) && (old.L2FirstDoorOpen != current.L2FirstDoorOpen)){
        vars.ilStage++;
	return true;
    }
    if ((vars.ilStage == 1) && (old.L2ElevDoorOpen != current.L2ElevDoorOpen)) {
	vars.ilStage = -1;
	return true;
    }

    // Office
    if ((vars.ilStage == 0) && (old.CapsuleTouch != current.CapsuleTouch) && (vars.WasVendingDoorOpened)){   
        vars.ilStage++;
	return true;
    }
    if ((vars.ilStage == 1) && (old.OfficeSkipDoorOpen != current.OfficeSkipDoorOpen)) {
	vars.ilStage = -1;
	return true;
    }
    
    // Main Hall
    if ((vars.ilStage == 0) && (old.PicturePuzzleFinished != current.PicturePuzzleFinished)){
        vars.WasPicturePuzzleDone = true;
        vars.ilStage++;
	return true;
    }
    if ((vars.ilStage == 1) && (vars.WasPicturePuzzleDone == true) && (old.CapsuleTouch != current.CapsuleTouch)){
        vars.ilStage++; 
	return true;
    }
    if ((vars.ilStage == 2) && (vars.WasPicturePuzzleDone == true) && (old.CapsuleTouch != current.CapsuleTouch)){
        vars.ilStage = -1;
	return true;
    }

    // RFYL
    if ((vars.ilStage == 0) && (old.SlideBed1 != current.SlideBed1)){
        vars.ilStage++;
	return true;
    }
    if ((vars.ilStage == 1) && (old.SlideBed2 != current.SlideBed2)) {
	vars.ilStage = -1;
	return true;
    }
    
    // FOW
    if ((vars.ilStage == 0 || vars.ilStage == 1) && (old.Level10Load != current.Level10Load)){
        print("Fow Load");
        vars.ilStage++;
	return vars.ilStage == 2;
    }
    if ((vars.ilStage == 2) && (old.JuicePickup != current.JuicePickup)){
        vars.ilStage++;
	return true;
    }
    if ((vars.ilStage == 3) && (old.JuicePickup != current.JuicePickup)){
        vars.ilStage = -1;
	return true;
    }

    // Snackrooms 
    if ((vars.ilStage == 0) && (old.TypeWriterClick != current.TypeWriterClick)){
        vars.ilStage++;
	return true;
    }
    if ((vars.ilStage == 1) && (old.TypeWriterCompleted != current.TypeWriterCompleted)) {
	vars.ilStage = -1;
	return true;
    }

    // Hotel Chase
    if ((vars.ilStage == 0) && (old.DashLeverUsed != current.DashLeverUsed)){
        vars.ilStage++;
	return true;
    }
    if ((vars.ilStage == 1) && (old.DashChainsawDoorOpened != current.DashChainsawDoorOpened)) {
	vars.ilStage = -1;
	return true;
    }
    
    // Grassrooms
    if ((vars.ilStage == 0) && (old.RopePickup != current.RopePickup)){
        vars.ilStage++;
	return true;
    }
    if ((vars.ilStage == 1) && (old.UseRope != current.UseRope)) {
	vars.ilStage = -1;
	return true;
    }
}

reset
{
    if ((current.IsInHubGM == 1) && ((((old.RestartLevel != current.RestartLevel) || (old.Death != current.Death)) && (old.LoadingStart != current.LoadingStart)) || (old.ContinueButton != current.ContinueButton))) return true;
}

isLoading
{
	return vars.LoadingState;
}

onReset
{
    vars.HasStarted = false;
    vars.HasExited = false;
    vars.WasEnding = false;
    vars.LoadingState = true;

    vars.ilStage = 0;
}

exit
{
    vars.HasExited = true;
    vars.WasEnding = false;
    vars.LoadingState = true;
    timer.IsGameTimePaused = true;
}