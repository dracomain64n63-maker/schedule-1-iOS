#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Schedule1PoliceLights.generated.h"

class UPointLightComponent;
class USceneComponent;

UCLASS()
class SCHEDULE1_API ASchedule1PoliceLights : public AActor
{
    GENERATED_BODY()

public:
    ASchedule1PoliceLights();

protected:
    virtual void BeginPlay() override;

private:
    UPROPERTY(VisibleAnywhere)
    TObjectPtr<USceneComponent> SceneRoot;

    UPROPERTY(VisibleAnywhere)
    TObjectPtr<UPointLightComponent> RedLight;

    UPROPERTY(VisibleAnywhere)
    TObjectPtr<UPointLightComponent> BlueLight;

    bool bRedActive = true;

    void ToggleLights();
};