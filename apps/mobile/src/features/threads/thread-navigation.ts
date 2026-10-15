import type { EnvironmentThreadShell } from "@t3tools/client-runtime/state/shell";

import { scopedThreadKey } from "../../lib/scopedEntities";
import type { ThreadListV2ListItem } from "./threadListV2";

export type ThreadNavigationListItem = ThreadListV2ListItem | { readonly type: "v2-show-more" };
export type ThreadNavigationDirection = "previous" | "next";

/** Follow the rendered order, skipping shelf headers, pending tasks and pagination. */
export function adjacentThreadTarget(
  items: ReadonlyArray<ThreadNavigationListItem>,
  currentThreadKey: string,
  direction: ThreadNavigationDirection,
): EnvironmentThreadShell | null {
  const currentIndex = items.findIndex(
    (item) =>
      item.type === "v2-thread" &&
      scopedThreadKey(item.item.thread.environmentId, item.item.thread.id) === currentThreadKey,
  );
  if (currentIndex < 0) return null;
  const step = direction === "previous" ? -1 : 1;
  for (let index = currentIndex + step; index >= 0 && index < items.length; index += step) {
    const item = items[index];
    if (item?.type === "v2-thread") return item.item.thread;
  }
  return null;
}

export const COMPOSER_SWIPE_ACTIVATION_DISTANCE = 32;
export const COMPOSER_SWIPE_MAX_VERTICAL_DISTANCE = 16;

/** A released, deliberate horizontal swipe changes one thread; left advances to next. */
export function composerThreadSwipeDirection(
  translationX: number,
  translationY: number,
  success: boolean,
  thread: {
    readonly originThreadKey: string | null;
    readonly currentThreadKey: string;
  },
): ThreadNavigationDirection | null {
  if (
    !success ||
    thread.originThreadKey !== thread.currentThreadKey ||
    Math.abs(translationX) < 64 ||
    Math.abs(translationY) > COMPOSER_SWIPE_MAX_VERTICAL_DISTANCE
  ) {
    return null;
  }
  return translationX < 0 ? "next" : "previous";
}
