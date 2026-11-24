#include "Schedule1BootMenu.h"
#include "Components/Button.h"
#include "Components/CanvasPanel.h"
#include "Components/CanvasPanelSlot.h"
#include "Components/TextBlock.h"
#include "Components/VerticalBox.h"
#include "Components/VerticalBoxSlot.h"
#include "Kismet/GameplayStatics.h"
#include "Kismet/KismetSystemLibrary.h"
#include "GameFramework/PlayerController.h"

void USchedule1BootMenu::NativeConstruct()
{
    Super::NativeConstruct();

    if (!WidgetTree || WidgetTree->RootWidget)
    {
        return;
    }

    UCanvasPanel* Root = WidgetTree->ConstructWidget<UCanvasPanel>(UCanvasPanel::StaticClass(), TEXT("Root"));
    WidgetTree->RootWidget = Root;

    UVerticalBox* Menu = WidgetTree->ConstructWidget<UVerticalBox>(UVerticalBox::StaticClass(), TEXT("Menu"));
    UCanvasPanelSlot* MenuSlot = Root->AddChildToCanvas(Menu);
    MenuSlot->SetAnchors(FAnchors(0.5f, 0.5f, 0.5f, 0.5f));
    MenuSlot->SetAlignment(FVector2D(0.5f, 0.5f));
    MenuSlot->SetPosition(FVector2D(0.0f, 10.0f));
    MenuSlot->SetSize(FVector2D(420.0f, 300.0f));

    UTextBlock* Title = WidgetTree->ConstructWidget<UTextBlock>(UTextBlock::StaticClass(), TEXT("Title"));
    Title->SetText(FText::FromString(TEXT("SCHEDULE 1")));
    Title->SetColorAndOpacity(FSlateColor(FLinearColor(0.25f, 0.9f, 0.42f, 1.0f)));
    Menu->AddChildToVerticalBox(Title);

    PlayButton = WidgetTree->ConstructWidget<UButton>(UButton::StaticClass(), TEXT("PlayButton"));
    UTextBlock* PlayText = WidgetTree->ConstructWidget<UTextBlock>(UTextBlock::StaticClass(), TEXT("PlayText"));
    PlayText->SetText(FText::FromString(TEXT("PLAY")));
    PlayButton->AddChild(PlayText);
    Menu->AddChildToVerticalBox(PlayButton);
    PlayButton->OnClicked.AddDynamic(this, &USchedule1BootMenu::OnPlayClicked);

    SettingsButton = WidgetTree->ConstructWidget<UButton>(UButton::StaticClass(), TEXT("SettingsButton"));
    UTextBlock* SettingsText = WidgetTree->ConstructWidget<UTextBlock>(UTextBlock::StaticClass(), TEXT("SettingsText"));
    SettingsText->SetText(FText::FromString(TEXT("SETTINGS")));
    SettingsButton->AddChild(SettingsText);
    Menu->AddChildToVerticalBox(SettingsButton);
    SettingsButton->OnClicked.AddDynamic(this, &USchedule1BootMenu::OnSettingsClicked);

    QuitButton = WidgetTree->ConstructWidget<UButton>(UButton::StaticClass(), TEXT("QuitButton"));
    UTextBlock* QuitText = WidgetTree->ConstructWidget<UTextBlock>(UTextBlock::StaticClass(), TEXT("QUIT")));
    QuitButton->AddChild(QuitText);
    Menu->AddChildToVerticalBox(QuitButton);
    QuitButton->OnClicked.AddDynamic(this, &USchedule1BootMenu::OnQuitClicked);
}

void USchedule1BootMenu::OnPlayClicked()
{
    if (APlayerController* PC = GetOwningPlayer())
    {
        PC->SetInputMode(FInputModeGameOnly());
        PC->bShowMouseCursor = false;
    }
    RemoveFromParent();
}

void USchedule1BootMenu::OnSettingsClicked()
{
    // Placeholder: settings screen will be added as a separate step.
}

void USchedule1BootMenu::OnQuitClicked()
{
    if (APlayerController* PC = GetOwningPlayer())
    {
        UKismetSystemLibrary::QuitGame(this, PC, EQuitPreference::Quit, false);
    }
}