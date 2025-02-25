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

import { JArrayList } from './JArrayList';

import { Poolable } from './Poolable';

/**
 * An object pool for recycling of object instances extending Poolable.
 *
 *
 * Cost/Benefit :
 *   Cost - The pool can only contain objects extending Poolable.
 *   Benefit - The pool can very quickly determine if an object is elligable for storage without iteration.
 *   Benefit - The pool can also know if an instance of Poolable is already stored in a different pool instance.
 *   Benefit - The pool can grow as needed, if it is empty
 *   Cost - However, refilling the pool when it is empty might incur a time cost with sufficiently large capacity.  Set the replenishPercentage to a lower number if this is a concern.
 */
export class ObjectPool<T extends Poolable> {
  private static ids = 0;
  public poolId: number = 0;
  private desiredCapacity: number = 0;
  private objects: Object[] | null = null;
  private objectsPointer: number = 0;
  private modelObject: T | null = null;
  private replenishPercentage: number = 0;

  /**
   * Returns the id of the given pool instance.
   *
   * @return an integer ID belonging to this pool instance.
   */
  public getPoolId(): number {
    return this.poolId;
  }

  /**
   * Returns an ObjectPool instance, of a given starting capacity, that recycles instances of a given Poolable object.
   *
   * @param withCapacity A positive integer value.
   * @param object An instance of the object that the pool should recycle.
   * @return
   */
  public static create(withCapacity: number, object: Poolable) {
    let result = new ObjectPool<Poolable>(withCapacity, object);
    result.poolId = ObjectPool.ids;
    ObjectPool.ids++;

    return result;
  }

  constructor(withCapacity: number, object: T) {
    if (withCapacity <= 0) {
      throw new Error("Object Pool must be instantiated with a capacity greater than 0!");
    }
    this.desiredCapacity = withCapacity;
    this.objects = new Array<Object>(this.desiredCapacity);
    this.objectsPointer = 0;
    this.modelObject = object;
    this.replenishPercentage = 1.0;
    this.refillPool();
  }

  /**
   * Set the percentage of the pool to replenish on empty.  Valid values are between
   * 0.00f and 1.00f
   *
   * @param percentage a value between 0 and 1, representing the percentage of the pool to replenish.
   */
  public setReplenishPercentage(percentage: number) {
    let p = percentage;
    if (p > 1) {
      p = 1;
    }
    else if (p < 0) {
      p = 0;
    }
    this.replenishPercentage = p;
    return this;
  }

  public getReplenishPercentage(): number {
    return this.replenishPercentage;
  }

  /*private refillPool() {
    this.refillPool(this.replenishPercentage);
  }
*/
  private refillPool(percentage?: number) {

    if (percentage == null) {
      percentage = this.replenishPercentage
    }

    let portionOfCapacity = (this.desiredCapacity * percentage);

    if (portionOfCapacity < 1) {
      portionOfCapacity = 1;
    } else if (portionOfCapacity > this.desiredCapacity) {
      portionOfCapacity = this.desiredCapacity;
    }

    for (let i = 0; i < portionOfCapacity; i++) {
      if (this.objects && this.modelObject) {
        let poolableObj = this.modelObject.instantiate();
        if (poolableObj !== null) {
          this.objects[i] = poolableObj;
        }

      }
    }
    this.objectsPointer = portionOfCapacity - 1;
  }

  /**
   * Returns an instance of Poolable.  If get() is called with an empty pool, the pool will be
   * replenished.  If the pool capacity is sufficiently large, this could come at a performance
   * cost.
   *
   * @return An instance of Poolable object T
   */
  public get(): T {

    if (this.objectsPointer == -1 && this.replenishPercentage > 0.0) {
      this.refillPool();
    }

    if (!this.objects) {
      this.objects = new Array<Poolable>(this.desiredCapacity);
    }
    let result: T = this.objects[this.objectsPointer] as T;
    result.currentOwnerId = Poolable.NO_OWNER;
    this.objectsPointer--;

    return result;
  }

  /**
   * Recycle an instance of Poolable that this pool is capable of generating.
   * The T instance passed must not already exist inside this or any other ObjectPool instance.
   *
   * @param object An object of type T to recycle
   */
  public recycle(object: T) {
    if (object.currentOwnerId != Poolable.NO_OWNER) {
      if (object.currentOwnerId == this.poolId) {
        throw new Error("The object passed is already stored in this pool!");
      } else {
        throw new Error("The object to recycle already belongs to poolId " + object.currentOwnerId + ".  Object cannot belong to two different pool instances simultaneously!");
      }
    }

    this.objectsPointer++;
    if (this.objects) {
      if (this.objectsPointer >= this.objects.length) {
        this.resizePool();
      }
      object.currentOwnerId = this.poolId;
      this.objects[this.objectsPointer] = object;
    }
  }

  /**
   * Recycle a List of Poolables that this pool is capable of generating.
   * The T instances passed must not already exist inside this or any other ObjectPool instance.
   *
   * @param objects A list of objects of type T to recycle
   */
  //    public   recycle( objects:Array<T>){
  public recycleArray(objects: JArrayList<T>) {
    while (objects.size() + this.objectsPointer + 1 > this.desiredCapacity) {
      this.resizePool();
    }
    let objectsListSize = objects.size();

    // Not relying on recycle(T object) because this is more performant.
    if (this.objects) {
      for (let i = 0; i < objectsListSize; i++) {
        let object: T = objects.get(i);
        if (object.currentOwnerId != Poolable.NO_OWNER) {
          if (object.currentOwnerId == this.poolId) {
            throw new Error("The object passed is already stored in this pool!");
          } else {
            throw new Error("The object to recycle already belongs to poolId " + object.currentOwnerId + ".  Object cannot belong to two different pool instances simultaneously!");
          }
        }
        object.currentOwnerId = this.poolId;
        this.objects[this.objectsPointer + 1 + i] = object;
      }
    }
    this.objectsPointer += objectsListSize;
  }

  private resizePool() {
    let oldCapacity = this.desiredCapacity;
    this.desiredCapacity *= 2;
    let temp: Object[] = new Array<Object>(this.desiredCapacity);
    if (this.objects) {
      for (let i = 0; i < oldCapacity; i++) {
        temp[i] = this.objects[i];
      }
    }
    this.objects = temp;
  }

  /**
   * Returns the capacity of this object pool.  Note : The pool will automatically resize
   * to contain additional objects if the user tries to add more objects than the pool's
   * capacity allows, but this comes at a performance cost.
   *
   * @return The capacity of the pool.
   */
  public getPoolCapacity(): number {
    return this.objects ? this.objects.length : 0;
  }

  /**
   * Returns the number of objects remaining in the pool, for diagnostic purposes.
   *
   * @return The number of objects remaining in the pool.
   */
  public getPoolCount(): number {
    return this.objectsPointer + 1;
  }
}

