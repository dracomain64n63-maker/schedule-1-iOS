#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "Schedule1GameMode.generated.h"

UCLASS()
class SCHEDULE1_API ASchedule1GameMode : public AGameModeBase
{
    GENERATED_BODY()

public:
    ASchedule1GameMode();
    virtual void BeginPlay() override;
};