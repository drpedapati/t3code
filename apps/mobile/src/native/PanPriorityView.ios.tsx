import { requireNativeView } from "expo";
import type { ViewProps } from "react-native";
import { withUniwind } from "uniwind";

export const PanPriorityView = withUniwind(
  requireNativeView<ViewProps>("T3NativeControls", "PanPriority"),
);
