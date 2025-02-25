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

/**
 * 移植的Rect类
 * @param left
 * @param top
 * @param right
 * @param bottom
 * @param r
 */
export default class MyRect {
  left: number = 0;
  top: number = 0;
  right: number = 0;
  bottom: number = 0;

  /**
   * Create a new rectangle with the specified coordinates. Note: no range
   * checking is performed, so the caller must ensure that left <= right and
   * top <= bottom.
   *
   * @param left   The X coordinate of the left side of the rectangle
   * @param top    The Y coordinate of the top of the rectangle
   * @param right  The X coordinate of the right side of the rectangle
   * @param bottom The Y coordinate of the bottom of the rectangle
   */
  constructor(left?: number, top?: number, right?: number, bottom?: number, r?: MyRect) {
    this.left = left == undefined ? 0 : left
    this.top = top == undefined ? 0 : top;
    this.right = right == undefined ? 0 : right;
    this.bottom = bottom == undefined ? 0 : bottom;
    if (r != null || r != undefined) {
      this.left = r.left;
      this.top = r.top;
      this.right = r.right;
      this.bottom = r.bottom;
    }
  }

  /**
   * Returns a copy of {@code r} if {@code r} is not {@code null}, or {@code null} otherwise.
   *
   * @hide
   */
  public static copyOrNull(r: MyRect): MyRect | null {
    return r == null ? null : new MyRect(r.left, r.top, r.right, r.bottom);
  }

  public equals(o: MyRect): boolean {
    if (this == o) return true;
    if (o == null || this != o) return false;
    return this.left == o.left && this.top == o.top && this.right == o.right && this.bottom == o.bottom;
  }

  public toString(): string {
    let sb: string = "";
    sb += "Rect(";
    sb += this.left;
    sb += ", ";
    sb += this.top;
    sb += " - ";
    sb += this.right;
    sb += ", ";
    sb += this.bottom;
    sb += ")";
    return sb;
  }


  /**
   * Returns true if the rectangle is empty (left >= right or top >= bottom)
   */
  public isEmpty(): boolean {
    return this.left >= this.right || this.top >= this.bottom;
  }

  /**
   * @return the rectangle's width. This does not check for a valid rectangle
   * (i.e. left <= right) so the result may be negative.
   */
  public width(): number {
    return this.right - this.left;
  }

  /**
   * @return the rectangle's height. This does not check for a valid rectangle
   * (i.e. top <= bottom) so the result may be negative.
   */
  public height(): number {
    return this.bottom - this.top;
  }

  /**
   * @return the horizontal center of the rectangle. If the computed value
   *         is fractional, this method returns the largest integer that is
   *         less than the computed value.
   */
  public centerX(): number {
    return (this.left + this.right) >> 1;
  }

  /**
   * @return the vertical center of the rectangle. If the computed value
   *         is fractional, this method returns the largest integer that is
   *         less than the computed value.
   */
  public centerY(): number {
    return (this.top + this.bottom) >> 1;
  }

  /**
   * @return the exact horizontal center of the rectangle as a float.
   */
  public exactCenterX(): number {
    return (this.left + this.right) * 0.5;
  }

  /**
   * @return the exact vertical center of the rectangle as a float.
   */
  public exactCenterY(): number {
    return (this.top + this.bottom) * 0.5;
  }

  /**
   * Set the rectangle to (0,0,0,0)
   */
  public setEmpty() {
    this.left = this.right = this.top = this.bottom = 0;
  }

  /**
   * Set the rectangle's coordinates to the specified values. Note: no range
   * checking is performed, so it is up to the caller to ensure that
   * left <= right and top <= bottom.
   *
   * @param left   The X coordinate of the left side of the rectangle
   * @param top    The Y coordinate of the top of the rectangle
   * @param right  The X coordinate of the right side of the rectangle
   * @param bottom The Y coordinate of the bottom of the rectangle
   */
  public set(left: number, top: number, right: number, bottom: number) {
    this.left = left;
    this.top = top;
    this.right = right;
    this.bottom = bottom;
  }

  /**
   * Offset the rectangle by adding dx to its left and right coordinates, and
   * adding dy to its top and bottom coordinates.
   *
   * @param dx The amount to add to the rectangle's left and right coordinates
   * @param dy The amount to add to the rectangle's top and bottom coordinates
   */
  public offset(dx: number, dy: number) {
    this.left += dx;
    this.top += dy;
    this.right += dx;
    this.bottom += dy;
  }

  /**
   * Offset the rectangle to a specific (left, top) position,
   * keeping its width and height the same.
   *
   * @param newLeft   The new "left" coordinate for the rectangle
   * @param newTop    The new "top" coordinate for the rectangle
   */
  public offsetTo(newLeft: number, newTop: number) {
    this.right += newLeft - this.left;
    this.bottom += newTop - this.top;
    this.left = newLeft;
    this.top = newTop;
  }


  /**
   * Insets the rectangle on all sides specified by the insets.
   * @hide
  * @param left The amount to add from the rectangle's left
   * @param top The amount to add from the rectangle's top
   * @param right The amount to subtract from the rectangle's right
   * @param bottom The amount to subtract from the rectangle's bottom
   */
  public inset(left: number, top: number, right: number, bottom: number) {
    this.left += left;
    this.top += top;
    this.right -= right;
    this.bottom -= bottom;
  }

  /**
   * Returns true if (x,y) is inside the rectangle. The left and top are
   * considered to be inside, while the right and bottom are not. This means
   * that for a x,y to be contained: left <= x < right and top <= y < bottom.
   * An empty rectangle never contains any point.
   *
   * @param x The X coordinate of the point being tested for containment
   * @param y The Y coordinate of the point being tested for containment
   * @return true iff (x,y) are contained by the rectangle, where containment
   *              means left <= x < right and top <= y < bottom
   */
  public contains(x: number, y: number): boolean {
    return this.left < this.right && this.top < this.bottom // check for empty first
    && x >= this.left && x < this.right && y >= this.top && y < this.bottom;
  }
}