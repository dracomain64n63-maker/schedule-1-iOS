#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "Schedule1BootMenu.generated.h"

class UButton;
class UTextBlock;
class UVerticalBox;

UCLASS()
class SCHEDULE1_API USchedule1BootMenu : public UUserWidget
{
    GENERATED_BODY()

protected:
    virtual void NativeConstruct() override;

private:
    UPROPERTY()
    TObjectPtr<UButton> PlayButton;

    UPROPERTY()
    TObjectPtr<UButton> SettingsButton;

    UPROPERTY()
    TObjectPtr<UButton> QuitButton;

    UFUNCTION()
    void OnPlayClicked();

    UFUNCTION()
    void OnSettingsClicked();

    UFUNCTION()
    void OnQuitClicked();
};