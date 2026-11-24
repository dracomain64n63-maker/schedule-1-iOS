#include "Schedule1Character.h"
#include "Schedule1PlayerController.h"
#include "Camera/CameraComponent.h"
#include "Components/CapsuleComponent.h"
#include "Engine/Engine.h"
#include "Engine/World.h"
#include "DrawDebugHelpers.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "GameFramework/PlayerController.h"

ASchedule1Character::ASchedule1Character()
{
    PrimaryActorTick.bCanEverTick = false;

    GetCapsuleComponent()->InitCapsuleSize(42.0f, 96.0f);

    FirstPersonCamera = CreateDefaultSubobject<UCameraComponent>(TEXT("FirstPersonCamera"));
    FirstPersonCamera->SetupAttachment(GetCapsuleComponent());
    FirstPersonCamera->SetRelativeLocation(FVector(0.0f, 0.0f, 64.0f));
    FirstPersonCamera->bUsePawnControlRotation = true;

    bUseControllerRotationYaw = true;
    bUseControllerRotationPitch = false;
    bUseControllerRotationRoll = false;

    GetCharacterMovement()->MaxWalkSpeed = 420.0f;
    GetCharacterMovement()->JumpZVelocity = 420.0f;
    GetCharacterMovement()->AirControl = 0.25f;
}

void ASchedule1Character::BeginPlay()
{
    Super::BeginPlay();
}

void ASchedule1Character::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAxis(TEXT("MoveForward"), this, &ASchedule1Character::MoveForward);
    PlayerInputComponent->BindAxis(TEXT("MoveRight"), this, &ASchedule1Character::MoveRight);
    PlayerInputComponent->BindAxis(TEXT("Turn"), this, &ASchedule1Character::Turn);
    PlayerInputComponent->BindAxis(TEXT("LookUp"), this, &ASchedule1Character::LookUp);
    PlayerInputComponent->BindAction(TEXT("Jump"), IE_Pressed, this, &ACharacter::Jump);
    PlayerInputComponent->BindAction(TEXT("Jump"), IE_Released, this, &ACharacter::StopJumping);
    PlayerInputComponent->BindAction(TEXT("Interact"), IE_Pressed, this, &ASchedule1Character::Interact);
}

void ASchedule1Character::MoveForward(float Value)
{
    if (Controller && FMath::Abs(Value) > KINDA_SMALL_NUMBER)
    {
        if (ASchedule1PlayerController* PC = Cast<ASchedule1PlayerController>(Controller))
        {
            if (PC->IsInputKeyDown(EKeys::Gamepad_LeftY) || PC->IsInputKeyDown(EKeys::Gamepad_LeftX))
            {
                PC->NotifyGamepadInput();
            }
        }
        AddMovementInput(GetActorForwardVector(), Value);
    }
}

void ASchedule1Character::MoveRight(float Value)
{
    if (Controller && FMath::Abs(Value) > KINDA_SMALL_NUMBER)
    {
        if (ASchedule1PlayerController* PC = Cast<ASchedule1PlayerController>(Controller))
        {
            PC->NotifyGamepadInput();
        }
        AddMovementInput(GetActorRightVector(), Value);
    }
}

void ASchedule1Character::Turn(float Value)
{
    if (Controller && FMath::Abs(Value) > KINDA_SMALL_NUMBER)
    {
        if (ASchedule1PlayerController* PC = Cast<ASchedule1PlayerController>(Controller))
        {
            PC->NotifyGamepadInput();
        }
    }
    AddControllerYawInput(Value);
}

void ASchedule1Character::LookUp(float Value)
{
    if (Controller && FMath::Abs(Value) > KINDA_SMALL_NUMBER)
    {
        if (ASchedule1PlayerController* PC = Cast<ASchedule1PlayerController>(Controller))
        {
            PC->NotifyGamepadInput();
        }
    }
    AddControllerPitchInput(Value);
}

void ASchedule1Character::Interact()
{
    if (!FirstPersonCamera || !GetWorld())
    {
        return;
    }

    const FVector Start = FirstPersonCamera->GetComponentLocation();
    const FVector End = Start + FirstPersonCamera->GetForwardVector() * 350.0f;
    FHitResult Hit;
    FCollisionQueryParams Params;
    Params.AddIgnoredActor(this);

    if (GetWorld()->LineTraceSingleByChannel(Hit, Start, End, ECC_Visibility, Params))
    {
        if (GEngine)
        {
            const FString HitName = Hit.GetActor() ? Hit.GetActor()->GetName() : TEXT("object");
            GEngine->AddOnScreenDebugMessage(-1, 2.0f, FColor::Green,
                FString::Printf(TEXT("Interacted with: %s"), *HitName));
        }
    }
}