#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "TimerManager.h"
#include "Schedule1PlayerController.generated.h"

class UTouchInterface;

UCLASS()
class SCHEDULE1_API ASchedule1PlayerController : public APlayerController
{
    GENERATED_BODY()

public:
    virtual void BeginPlay() override;
    virtual bool InputKey(const FInputKeyEventArgs& EventArgs) override;

    UFUNCTION(BlueprintCallable, Category = "Input")
    void NotifyGamepadInput();

    UFUNCTION(BlueprintPure, Category = "Input")
    bool IsGamepadConnectedOrActive() const { return bGamepadConnected || bGamepadActive; }

protected:
    virtual void PlayerTick(float DeltaTime) override;

private:
    UPROPERTY()
    TObjectPtr<UTouchInterface> DefaultMobileTouchInterface;

    bool bGamepadConnected = false;
    bool bGamepadActive = false;
    FTimerHandle ControllerPollTimer;

    void RefreshControllerConnection();
    void ShowMobileControls();
    void HideMobileControls();
};