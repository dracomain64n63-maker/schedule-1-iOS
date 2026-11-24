#include "Schedule1HUD.h"
#include "Schedule1PlayerController.h"
#include "Engine/Canvas.h"
#include "Engine/Font.h"

void ASchedule1HUD::DrawHUD()
{
    Super::DrawHUD();

    const ASchedule1PlayerController* PC =
        Cast<ASchedule1PlayerController>(PlayerOwner);

    if (PC && PC->IsGamepadConnectedOrActive() && Canvas)
    {
        UFont* Font = GEngine ? GEngine->GetMediumFont() : nullptr;
        if (Font)
        {
            const FString Status = TEXT("CONTROLLER CONNECTED");
            DrawText(Status, FColor(40, 220, 90), 36.0f, 32.0f, Font, 1.0f, false);
        }
    }
}