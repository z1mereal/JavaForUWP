package banditvault.xboxcompat.mixin;

import banditvault.xboxcompat.XboxCompatLog;
import net.minecraft.class_6396;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(class_6396.class)
public abstract class SystemDetailsOshiBypassMixin {
    @Inject(method = "method_68673", at = @At("HEAD"), cancellable = true)
    private void banditvault$skipOshiHardwareProbe(CallbackInfo ci) {
        XboxCompatLog.log("Skipping OSHI hardware probe in Xbox sandbox");
        ci.cancel();
    }
}
