#pragma once

#include "CoreMinimal.h"
#include "GameFramework/HUD.h"
#include "Schedule1HUD.generated.h"

UCLASS()
class SCHEDULE1_API ASchedule1HUD : public AHUD
{
    GENERATED_BODY()

public:
    virtual void DrawHUD() override;
};