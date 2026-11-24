#include "Schedule1PoliceLights.h"
#include "Components/PointLightComponent.h"
#include "Components/SceneComponent.h"
#include "Engine/World.h"
#include "TimerManager.h"

ASchedule1PoliceLights::ASchedule1PoliceLights()
{
    PrimaryActorTick.bCanEverTick = false;

    SceneRoot = CreateDefaultSubobject<USceneComponent>(TEXT("Root"));
    SetRootComponent(SceneRoot);

    RedLight = CreateDefaultSubobject<UPointLightComponent>(TEXT("RedEmergencyLight"));
    RedLight->SetupAttachment(SceneRoot);
    RedLight->SetRelativeLocation(FVector(0.0f, -35.0f, 25.0f));
    RedLight->SetLightColor(FLinearColor(1.0f, 0.0f, 0.02f));
    RedLight->SetIntensity(8000.0f);
    RedLight->SetAttenuationRadius(1200.0f);

    BlueLight = CreateDefaultSubobject<UPointLightComponent>(TEXT("BlueEmergencyLight"));
    BlueLight->SetupAttachment(SceneRoot);
    BlueLight->SetRelativeLocation(FVector(0.0f, 35.0f, 25.0f));
    BlueLight->SetLightColor(FLinearColor(0.02f, 0.12f, 1.0f));
    BlueLight->SetIntensity(0.0f);
    BlueLight->SetAttenuationRadius(1200.0f);
}

void ASchedule1PoliceLights::BeginPlay()
{
    Super::BeginPlay();
    GetWorldTimerManager().SetTimer(
        FTimerHandle(),
        this,
        &ASchedule1PoliceLights::ToggleLights,
        0.25f,
        true);
}

void ASchedule1PoliceLights::ToggleLights()
{
    bRedActive = !bRedActive;
    RedLight->SetIntensity(bRedActive ? 8000.0f : 0.0f);
    BlueLight->SetIntensity(bRedActive ? 0.0f : 8000.0f);
}