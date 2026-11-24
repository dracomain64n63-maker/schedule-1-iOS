#include "Schedule1PlayerController.h"
#include "Engine/Engine.h"
#include "Engine/TouchInterface.h"
#include "Engine/World.h"
#include "HAL/PlatformMisc.h"
#include "InputCoreTypes.h"
#include "TimerManager.h"

void ASchedule1PlayerController::BeginPlay()
{
    Super::BeginPlay();

    DefaultMobileTouchInterface = LoadObject<UTouchInterface>(
        nullptr,
        TEXT("/Engine/MobileResources/HUD/DefaultVirtualJoysticks.DefaultVirtualJoysticks"));

    RefreshControllerConnection();
    GetWorldTimerManager().SetTimer(
        ControllerPollTimer,
        this,
        &ASchedule1PlayerController::RefreshControllerConnection,
        0.5f,
        true);

    if (bGamepadConnected)
    {
        HideMobileControls();
    }
    else
    {
        ShowMobileControls();
    }
}

void ASchedule1PlayerController::PlayerTick(float DeltaTime)
{
    Super::PlayerTick(DeltaTime);
}

void ASchedule1PlayerController::RefreshControllerConnection()
{
    const bool bNowConnected = FPlatformMisc::IsControllerConnected(0);
    if (bNowConnected != bGamepadConnected)
    {
        bGamepadConnected = bNowConnected;
        bGamepadActive = false;

        if (bGamepadConnected)
        {
            HideMobileControls();
        }
        else
        {
            ShowMobileControls();
        }
    }
}

void ASchedule1PlayerController::ShowMobileControls()
{
    if (DefaultMobileTouchInterface)
    {
        ActivateTouchInterface(DefaultMobileTouchInterface);
    }
}

void ASchedule1PlayerController::HideMobileControls()
{
    ActivateTouchInterface(nullptr);
}

void ASchedule1PlayerController::NotifyGamepadInput()
{
    bGamepadActive = true;
    HideMobileControls();
}

bool ASchedule1PlayerController::InputKey(const FInputKeyEventArgs& EventArgs)
{
    if (EventArgs.Event == IE_Pressed)
    {
        if (EventArgs.Key.IsGamepadKey())
        {
            NotifyGamepadInput();
        }
        else if (EventArgs.Key == EKeys::Touch1 ||
                 EventArgs.Key == EKeys::Touch2 ||
                 EventArgs.Key == EKeys::Touch3)
        {
            if (bGamepadConnected)
            {
                bGamepadActive = false;
                ShowMobileControls();
            }
        }
    }

    return Super::InputKey(EventArgs);
}