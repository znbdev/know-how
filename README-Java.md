Java
=====

---

# “**最大化解耦**”这个概念，以及“一个实现类对应一个抽象类/接口”是如何实现这一点的。

“解耦”（Decoupling）是指降低系统不同组件或模块之间的相互依赖程度。**最大化解耦**就是指让组件之间的依赖关系降到最低，最好是依赖于一个
**稳定的、不常变化的抽象定义**。

## 什么是耦合 (Coupling)?

**耦合**就是相互依赖。如果一个模块 A 的实现细节（比如它的类名、方法签名甚至内部逻辑）发生了变化，导致另一个模块 B
必须跟着修改，那么我们就说 A 和 B 是**高耦合**的。

### 🚨 高耦合的风险：

1. **牵一发动全身：** 哪怕是 A 中一个微小的改动，都可能引发 B 的一系列连锁反应，增加维护难度。
2. **难以测试：** 测试 B 时，必须要有 A 的真实实例。
3. **缺乏弹性：** 无法轻易替换 A 的实现。

## 抽象是如何实现“最大化解耦”的？

通过引入**抽象层**（接口或抽象类），我们不再让高层模块直接依赖低层模块的具体实现，而是让两者都依赖一个**中介**——这个中介就是抽象。

我们来看一个具体的例子：**用户通知服务**。

### ❌ 场景一：高耦合（直接依赖实现类）

假设我们有一个**订单模块**（高层模块），需要通知用户订单状态。我们一开始决定用电子邮件来通知。

```java
// 低层模块：具体的通知实现
class EmailNotifier {
    public void send(String userId, String message) {
        System.out.println("通过 Email 发送通知给：" + userId + "，内容：" + message);
        // ... 具体的邮件发送逻辑
    }
}

// 高层模块：业务逻辑，直接依赖 EmailNotifier
class OrderService {
    // OrderService 内部直接实例化和调用了具体的实现类
    private EmailNotifier notifier = new EmailNotifier();

    public void completeOrder(String userId, String orderId) {
        // ... 订单完成逻辑
        String message = "订单 " + orderId + " 已完成。";
        // 核心问题：OrderService 知道它使用的是 EmailNotifier
        notifier.send(userId, message);
    }
}
```

**问题所在：**

* `OrderService` 与 `EmailNotifier` 是**强耦合**的。
* 如果现在要求改成使用短信 `SmsNotifier`，或者未来要支持多种通知方式，我们**必须**修改 `OrderService` 的内部代码（换掉
  `new EmailNotifier()`）。
* 测试 `OrderService` 时，我们实际上也触发了真实的邮件发送逻辑，这不符合单元测试的原则。

### ✅ 场景二：最大化解耦（依赖抽象）

现在我们引入一个\*\*接口（抽象）\*\*作为中介。

```java
// 抽象层：定义规范
interface Notifier {
    void send(String userId, String message); // 抽象方法，定义“能做什么”
}

// 低层模块：具体的通知实现 1
class EmailNotifier implements Notifier {
    @Override
    public void send(String userId, String message) {
        System.out.println("通过 Email 发送通知给：" + userId + "，内容：" + message);
    }
}

// 低层模块：具体的通知实现 2 (未来扩展)
class SmsNotifier implements Notifier {
    @Override
    public void send(String userId, String message) {
        System.out.println("通过 SMS 短信发送通知给：" + userId + "，内容：" + message);
    }
}

// 高层模块：业务逻辑，依赖 Notifier 接口
class OrderService {
    // OrderService 不知道也不关心具体的实现类是什么
    // 它只知道它有一个 Notifier 能力的对象
    private Notifier notifier;

    // 通过构造器或Setter方法注入依赖（依赖注入/DI）
    public OrderService(Notifier notifier) {
        this.notifier = notifier;
    }

    public void completeOrder(String userId, String orderId) {
        // ... 订单完成逻辑
        String message = "订单 " + orderId + " 已完成。";

        // OrderService 只调用抽象规范中定义的方法
        notifier.send(userId, message);
    }
}
```

**解耦效果：**

1. **OrderService 对具体实现零依赖：** `OrderService` 现在只依赖于稳定的 `Notifier` 接口。它不知道自己调用的是
   `EmailNotifier` 还是 `SmsNotifier`。

2. **易于替换：** 如果我们想把通知方式从邮件切换到短信，我们只需要在**程序入口或配置层**替换注入给 `OrderService` 的对象即可，
   `OrderService` 的代码**一个字符都不需要改动**。

   ```java
   // 实例化和配置层 (通常是 main 方法或 Spring 容器)

   // 切换到邮件
   Notifier email = new EmailNotifier(); 
   OrderService service1 = new OrderService(email);
   service1.completeOrder("UserA", "Order123");

   // 切换到短信
   Notifier sms = new SmsNotifier();
   OrderService service2 = new OrderService(sms);
   service2.completeOrder("UserB", "Order456");
   ```

3. **易于测试：** 我们可以为 `Notifier` 接口创建一个 Mock 实现，在测试 `OrderService` 时，模拟 `send()`
   方法的行为，而无需担心真实的邮件服务器是否正常工作。

这就是“最大化解耦”的意义：**模块之间不再互相依赖具体的实现类，而是依赖于共同的抽象定义**
，从而使得系统的各个部分能够独立变化和替换，极大地提高了系统的灵活性和可维护性。

---

```java
// ----------------------- 1. 接口 (Interface) -----------------------
// 接口定义了一种“能力”或“契约”：任何实现该接口的类都必须具备燃料消耗的能力。
public interface FuelConsumable {

    // 抽象方法：定义了行为规范，但没有实现。
    // 任何实现该接口的类必须实现此方法。
    double calculateFuelEfficiency(double distance, double fuelUsed); 
    
    // Java 8 引入的默认方法：提供一个默认实现，子类可以选择性地重写。
    default void refill() {
        System.out.println("燃料箱正在加注燃料...");
    }
}

// ----------------------- 2. 抽象类 (Abstract Class) -----------------------
// 抽象类定义了一个“类族”的通用结构和行为骨架。
public abstract class AbstractVehicle {

    // 成员变量：抽象类可以有实例变量（维护状态）
    private String model;
    private int maxSpeed;

    // 构造器：抽象类可以有构造器，用于初始化通用属性
    public AbstractVehicle(String model, int maxSpeed) {
        this.model = model;
        this.maxSpeed = maxSpeed;
        System.out.println("创建了型号为 " + model + " 的抽象交通工具。");
    }

    // 普通方法：有具体实现的方法，供子类直接继承和复用
    public void startEngine() {
        System.out.println(model + " 引擎启动，准备就绪。");
    }

    // 抽象方法：定义了行为规范，但没有实现。
    // 任何非抽象子类必须实现此方法。
    public abstract void drive();
    
    // Getter 方法
    public String getModel() {
        return model;
    }
    public int getMaxSpeed() {
        return maxSpeed;
    }
}

// ----------------------- 3. 实现类 (Concrete Class) -----------------------
// 具体的汽车类，它：
// 1. 继承 (extends) 抽象类 AbstractVehicle，获得了通用属性和方法。
// 2. 实现 (implements) 接口 FuelConsumable，获得了燃料消耗的能力。
public class Car extends AbstractVehicle implements FuelConsumable {

    private int passengerCount;

    // 继承父类的构造器
    public Car(String model, int maxSpeed, int passengerCount) {
        super(model, maxSpeed); // 调用父类构造器初始化 model 和 maxSpeed
        this.passengerCount = passengerCount;
    }

    // 必须实现：继承自 AbstractVehicle 的抽象方法
    @Override
    public void drive() {
        System.out.println(getModel() + " 正在以最高时速 " + getMaxSpeed() + " km/h 的速度行驶，载客 " + passengerCount + " 人。");
    }

    // 必须实现：继承自 FuelConsumable 接口的抽象方法
    @Override
    public double calculateFuelEfficiency(double distance, double fuelUsed) {
        double efficiency = distance / fuelUsed;
        System.out.println(getModel() + " 的燃油效率为: " + String.format("%.2f", efficiency) + " km/L");
        return efficiency;
    }
    
    // (可选) 可以重写接口的默认方法，这里选择不重写，使用默认实现
}

// ----------------------- 4. 测试类 (Main Method) -----------------------
public class Main {
public static void main(String[] args) {
// 多态的应用：使用抽象类型引用具体对象
// 接口引用
FuelConsumable myFuelVehicle = new Car("Toyota Camry", 220, 4);
// 抽象类引用
AbstractVehicle myVehicle = (AbstractVehicle) myFuelVehicle;

        System.out.println("--- 抽象类方法调用（通用行为） ---");
        myVehicle.startEngine(); // 调用继承自抽象类的普通方法
        myVehicle.drive();      // 调用继承自抽象类，但在子类中实现的方法
        
        System.out.println("\n--- 接口方法调用（能力/契约） ---");
        myFuelVehicle.calculateFuelEfficiency(500, 40); // 调用接口中要求实现的方法
        myFuelVehicle.refill(); // 调用接口中提供的默认方法
    }
}
```

---

# Reference

- [Archived OpenJDK General-Availability Releases](https://jdk.java.net/archive/)
