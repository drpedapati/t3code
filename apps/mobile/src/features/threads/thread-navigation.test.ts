import { describe, expect, it } from "vite-plus/test";

import { composerThreadSwipeDirection } from "./thread-navigation";

const sameThread = {
  originThreadKey: "environment-1:thread-1",
  currentThreadKey: "environment-1:thread-1",
};

describe("composerThreadSwipeDirection", () => {
  it("maps a left swipe to previous and a right swipe to next", () => {
    expect(composerThreadSwipeDirection(-100, 8, true, sameThread)).toBe("previous");
    expect(composerThreadSwipeDirection(100, -8, true, sameThread)).toBe("next");
  });

  it("ignores taps, short drags and a swipe dragged back before release", () => {
    for (const x of [0, -10, 10, -63, 63]) {
      expect(composerThreadSwipeDirection(x, 0, true, sameThread)).toBeNull();
    }
    expect(composerThreadSwipeDirection(-64, 0, true, sameThread)).toBe("previous");
    expect(composerThreadSwipeDirection(64, 0, true, sameThread)).toBe("next");
  });

  it("rejects vertical scrolling and diagonal drift even after horizontal activation", () => {
    for (const [x, y] of [
      [0, 100],
      [100, 40],
      [-100, -40],
    ] as const) {
      expect(composerThreadSwipeDirection(x, y, true, sameThread)).toBeNull();
    }
  });

  it("never changes threads when the recognizer was cancelled", () => {
    expect(composerThreadSwipeDirection(-100, 0, false, sameThread)).toBeNull();
    expect(composerThreadSwipeDirection(100, 0, false, sameThread)).toBeNull();
  });

  it.each(["environment-1:thread-2", "environment-2:thread-1"])(
    "ignores a swipe that began before switching to %s",
    (currentThreadKey) => {
      for (const x of [-100, 100]) {
        expect(
          composerThreadSwipeDirection(x, 0, true, { ...sameThread, currentThreadKey }),
        ).toBeNull();
      }
    },
  );

  it("ignores an invalidated gesture even after returning to its original thread", () => {
    expect(
      composerThreadSwipeDirection(100, 0, true, { ...sameThread, originThreadKey: null }),
    ).toBeNull();
  });
});
