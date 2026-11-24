#include "Schedule1GameMode.h"
#include "Schedule1Character.h"
#include "Schedule1PlayerController.h"
#include "Schedule1HUD.h"
#include "Schedule1BootMenu.h"
#include "Blueprint/UserWidget.h"
#include "GameFramework/PlayerController.h"

ASchedule1GameMode::ASchedule1GameMode()
{
    DefaultPawnClass = ASchedule1Character::StaticClass();
    PlayerControllerClass = ASchedule1PlayerController::StaticClass();
    HUDClass = ASchedule1HUD::StaticClass();
}

void ASchedule1GameMode::BeginPlay()
{
    Super::BeginPlay();

    if (APlayerController* PC = GetWorld()->GetFirstPlayerController())
    {
        if (USchedule1BootMenu* Menu = CreateWidget<USchedule1BootMenu>(PC, USchedule1BootMenu::StaticClass()))
        {
            Menu->AddToViewport(100);
            PC->SetInputMode(FInputModeGameAndUI());
            PC->bShowMouseCursor = true;
        }
    }
}