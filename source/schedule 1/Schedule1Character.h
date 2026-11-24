#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "Schedule1Character.generated.h"

class UCameraComponent;

UCLASS()
class SCHEDULE1_API ASchedule1Character : public ACharacter
{
    GENERATED_BODY()

public:
    ASchedule1Character();

protected:
    virtual void BeginPlay() override;
    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;

private:
    UPROPERTY(VisibleAnywhere, Category = "Camera")
    TObjectPtr<UCameraComponent> FirstPersonCamera;

    void MoveForward(float Value);
    void MoveRight(float Value);
    void Turn(float Value);
    void LookUp(float Value);
    void Interact();
};