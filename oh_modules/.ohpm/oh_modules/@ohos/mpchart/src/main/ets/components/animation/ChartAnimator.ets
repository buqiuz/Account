/*
 * Copyright (C) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import animator, { AnimatorOptions, AnimatorResult } from '@ohos.animator';
import AnimatorUpdateListener from '../listener/AnimatorUpdateListener';

export default class ChartAnimator {
  /**
   * object that is updated upon animation update
   */
  private mListener: AnimatorUpdateListener;
  /**
   * The phase of drawn values on the y-axis.
   */
  protected mPhaseY: number = 1;
  /** The phase of drawn values on the x-axis. 0 - 1 */
  protected mPhaseX: number = 1;
  private isShowXCallback: boolean = false;
  private isShowYCallback: boolean = false;

  constructor(listener: AnimatorUpdateListener) {
    this.mListener = listener;
  }

  private xAnimator(duration: number, easing: string): AnimatorResult {
    let options: AnimatorOptions = {
      duration: duration,
      easing: easing,
      delay: 0,
      fill: "forwards",
      direction: "normal",
      iterations: 1,
      begin: 0,
      end: 1
    };
    let animatorResult = animator.create(options);
    animatorResult.onframe = (value) => {
      this.mPhaseX = value;
      if (this.isShowXCallback && this.mListener) {
        this.mListener.onAnimationUpdate(animatorResult);
      }
    }

    return animatorResult;
  }

  private yAnimator(duration: number, easing: string): AnimatorResult {
    let options: AnimatorOptions = {
      duration: duration,
      easing: easing,
      delay: 0,
      fill: "forwards",
      direction: "normal",
      iterations: 1,
      begin: 0,
      end: 1
    };
    let animatorResult = animator.create(options);
    animatorResult.onframe = (value) => {
      this.mPhaseY = value;
      if (this.isShowYCallback && this.mListener) {
        this.mListener.onAnimationUpdate(animatorResult);
      }
    }

    return animatorResult;
  }

  //
  // /**
  //    * Animates values along the X axis, in a linear fashion.
  //    *
  //    * @param durationMillis animation duration
  //    */
  // public animateX(durationMillis:number) {
  //   animateX(durationMillis, Easing.Linear);
  // }
  //
  /**
   * Animates values along the X axis.
   *
   * @param durationMillis animation duration
   * @param easing EasingFunction
   */
  public animateX(durationMillis: number): void;

  public animateX(durationMillis: number, easing: string): void;

  public animateX(durationMillis: number, easing?: string) {
    if (!easing) {
      easing = 'linear'
    }
    let animatorXResult = this.xAnimator(durationMillis, easing);
    this.isShowXCallback = true;
    this.isShowYCallback = false;
    animatorXResult.play();
  }

  //
  // /**
  //    * Animates values along both the X and Y axes, in a linear fashion.
  //    *
  //    * @param durationMillisX animation duration along the X axis
  //    * @param durationMillisY animation duration along the Y axis
  //    */
  //
  // public animateXY(durationMillisX:number,durationMillisY:number) {
  //   animateXY(durationMillisX, durationMillisY, Easing.Linear, Easing.Linear);
  // }
  //
  /**
   * Animates values along both the X and Y axes.
   *
   * @param durationMillisX animation duration along the X axis
   * @param durationMillisY animation duration along the Y axis
   * @param easing EasingFunction for both axes
   */

  public animateXY(durationMillisX: number, durationMillisY: number): void;

  public animateXY(durationMillisX: number, durationMillisY: number, easing: string): void;

  public animateXY(durationMillisX: number, durationMillisY: number, xEasing: string, yEasing: string): void;

  public animateXY(durationMillisX: number, durationMillisY: number, xEasing?: string, yEasing?: string) {
    if (!xEasing) {
      xEasing = 'linear'
    }
    if (!yEasing) {
      yEasing = 'linear'
    }
    let xAnimatorResult = this.xAnimator(durationMillisX, xEasing);
    let yAnimatorResult = this.yAnimator(durationMillisY, yEasing);

    if (durationMillisX > durationMillisY) {
      this.isShowXCallback = true;
      this.isShowYCallback = false;
    } else {
      this.isShowXCallback = false;
      this.isShowYCallback = true;
    }

    xAnimatorResult.play();
    yAnimatorResult.play();
  }

  //
  // /**
  //    * Animates values along both the X and Y axes.
  //    *
  //    * @param durationMillisX animation duration along the X axis
  //    * @param durationMillisY animation duration along the Y axis
  //    * @param easingX EasingFunction for the X axis
  //    * @param easingY EasingFunction for the Y axis
  //    */
  //
  // public animateXY(durationMillisX:number, durationMillisY:number, easingX:EasingFunction,
  //                  easingY:EasingFunction) {
  //
  //   let xAnimator = xAnimator(durationMillisX, easingX);
  //   let yAnimator = yAnimator(durationMillisY, easingY);
  //
  //   if (durationMillisX > durationMillisY) {
  //     xAnimator.addUpdateListener(mListener);
  //   } else {
  //     yAnimator.addUpdateListener(mListener);
  //   }
  //
  //   xAnimator.start();
  //   yAnimator.start();
  // }
  //
  // /**
  //    * Animates values along the Y axis, in a linear fashion.
  //    *
  //    * @param durationMillis animation duration
  //    */
  //
  // public animateY(durationMillis:number) {
  //   this.animateY(durationMillis, Easing.Linear);
  // }
  //
  /**
   * Animates values along the Y axis.
   *
   * @param durationMillis animation duration
   * @param easing EasingFunction
   */

  public animateY(durationMillis: number): void;

  public animateY(durationMillis: number, easing: string): void;

  public animateY(durationMillis: number, easing?: string) {
    if (!easing) {
      easing = 'linear'
    }
    let animatorY: AnimatorResult = this.yAnimator(durationMillis, easing);
    this.isShowXCallback = false;
    this.isShowYCallback = true;
    animatorY.play();
  }

  /**
   * Gets the Y axis phase of the animation.
   *
   * @return float value of {@link #mPhaseY}
   */
  public getPhaseY(): number {
    return this.mPhaseY;
  }

  /**
   * Sets the Y axis phase of the animation.
   *
   * @param phase float value between 0 - 1
   */
  public setPhaseY(phase: number) {
    if (phase > 1) {
      phase = 1;
    } else if (phase < 0) {
      phase = 0;
    }
    this.mPhaseY = phase;
  }

  /**
   * Gets the X axis phase of the animation.
   *
   * @return float value of {@link #mPhaseX}
   */
  public getPhaseX(): number {
    return this.mPhaseX;
  }

  /**
   * Sets the X axis phase of the animation.
   *
   * @param phase float value between 0 - 1
   */
  public setPhaseX(phase: number) {
    if (phase > 1) {
      phase = 1;
    } else if (phase < 0) {
      phase = 0;
    }
    this.mPhaseX = phase;
  }
}
