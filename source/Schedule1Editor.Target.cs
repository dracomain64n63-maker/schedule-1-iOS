using UnrealBuildTool;
using System.Collections.Generic;

public class Schedule1EditorTarget : TargetRules
{
    public Schedule1EditorTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Editor;
        DefaultBuildSettings = BuildSettingsVersion.V5;
        IncludeOrderVersion = EngineIncludeOrderVersion.Unreal5_5;
        ExtraModuleNames.Add("Schedule1");
    }
}