# Spring Batch 工作原理总结

## 一、核心概念

Spring Batch 是一个轻量级、全面的批处理框架，用于开发对企业系统日常运营至关重要的强大批处理应用程序。

### 1. 基本架构组件

```
JobLauncher → Job → Step → (ItemReader → ItemProcessor → ItemWriter)
```

- **Job**: 批处理作业的顶层抽象，代表整个批处理任务
- **Step**: 作业中的一个独立阶段，包含完整的读-处理-写流程
- **JobLauncher**: 启动作业的接口
- **JobRepository**: 持久化作业执行元数据（状态、进度等）

---

## 二、核心工作流程

### 1. 作业启动流程

```
1. JobLauncher 接收启动请求
2. 创建 JobExecution 和 StepExecution 对象
3. JobRepository 保存执行状态为 STARTING
4. 依次执行每个 Step
5. 更新最终状态为 COMPLETED/FAILED
```

### 2. Chunk 处理模式（核心机制）

Spring Batch 最常用的处理模式是 **Chunk-oriented Processing**：

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│ ItemReader  │────▶│ ItemProcessor│────▶│ ItemWriter   │
│ 读取单条数据 │     │ 处理单条数据  │     │ 批量写入数据  │
└─────────────┘     └──────────────┘     └──────────────┘
                         ▲                      │
                         │                      │
                    累积到 commit-interval      │
                         │                      │
                         └──────────────────────┘
                              事务提交点
```

**工作流程：**
1. **ItemReader** 逐条读取数据（一次一条）
2. **ItemProcessor** 逐条处理/转换数据（可选）
3. 将处理后的 item 累积到 chunk
4. 当达到 `commit-interval` 指定的数量时
5. **ItemWriter** 批量写入整个 chunk
6. 提交事务

---

## 三、关键组件详解

### 1. ItemReader（数据读取器）

负责从各种数据源读取数据：
- **FlatFileItemReader**: 读取平面文件（CSV、TXT）
- **JdbcCursorItemReader**: 通过 JDBC 游标读取数据库
- **JpaPagingItemReader**: 使用 JPA 分页读取
- **MongoItemReader**: 从 MongoDB 读取
- **MultiResourceItemReader**: 读取多个文件

**特点：**
- 每次调用 `read()` 返回一个 item
- 到达末尾时返回 `null`
- 支持重启时的状态恢复

### 2. ItemProcessor（数据处理器）

负责对数据进行业务逻辑处理：
- 数据转换（格式转换、计算等）
- 数据验证
- 数据过滤（返回 `null` 表示过滤掉该条数据）

**特点：**
- 可选组件，可以省略
- 输入输出类型可以不同
- 支持链式处理

### 3. ItemWriter（数据写入器）

负责将数据批量写入目标：
- **FlatFileItemWriter**: 写入平面文件
- **JdbcBatchItemWriter**: 批量写入数据库
- **JpaItemWriter**: 使用 JPA 写入
- **MongoItemWriter**: 写入 MongoDB
- **CompositeItemWriter**: 同时写入多个目标

**特点：**
- 接收一个 List<Item> 进行批量写入
- 在事务边界执行
- 支持重试和跳过机制

---

## 四、作业执行模型

### 1. 核心实体关系

```
JobInstance (作业实例)
    ├── JobExecution (作业执行)
    │       ├── StepExecution (步骤执行)
    │       │       └── ExecutionContext (执行上下文)
    │       └── ExecutionContext
    └── JobParameters (作业参数)
```

- **JobInstance**: 作业的唯一标识（Job + JobParameters）
- **JobExecution**: 作业的一次运行尝试
- **StepExecution**: 步骤的一次运行尝试
- **ExecutionContext**: 持久化的键值对，用于状态保存

### 2. 作业状态流转

```
STARTING → STARTED → 
    ├→ COMPLETED (成功)
    ├→ FAILED (失败)
    ├→ STOPPED (手动停止)
    └→ ABANDONED (被放弃)
```

---

## 五、高级特性

### 1. 事务管理

- 每个 chunk 在一个事务中执行
- 默认使用 Spring 的事务管理器
- 支持配置事务隔离级别和传播行为
- Chunk 大小决定事务边界

```java
@Bean
public Step step1() {
    return stepBuilderFactory.get("step1")
        .<Input, Output>chunk(10)  // 每10条提交一次事务
        .reader(reader())
        .processor(processor())
        .writer(writer())
        .build();
}
```

### 2. 重试与跳过机制

**重试（Retry）：**
- 针对临时性故障（网络抖动、死锁等）
- 可配置重试次数和异常类型
- 指数退避策略

**跳过（Skip）：**
- 针对不可恢复的错误
- 跳过有问题的记录，继续处理其他记录
- 记录跳过的项到日志或单独文件

```java
@Bean
public Step step1() {
    return stepBuilderFactory.get("step1")
        .<Input, Output>chunk(10)
        .reader(reader())
        .writer(writer())
        .faultTolerant()
        .retryLimit(3)
        .retry(DataAccessException.class)
        .skipLimit(10)
        .skip(IllegalArgumentException.class)
        .build();
}
```

### 3. 并行处理

**多线程 Step：**
```java
@Bean
public Step step1() {
    return stepBuilderFactory.get("step1")
        .<Input, Output>chunk(10)
        .reader(reader())
        .writer(writer())
        .taskExecutor(taskExecutor())  // 配置线程池
        .build();
}
```

**并行 Step：**
```java
@Bean
public Job parallelJob() {
    return jobBuilderFactory.get("parallelJob")
        .start(splitFlow())
        .end()
        .build();
}

@Bean
public Flow splitFlow() {
    return new FlowBuilder<SimpleFlow>("splitFlow")
        .split(taskExecutor())
        .add(flow1(), flow2())
        .build();
}
```

**分区（Partitioning）：**
- 将大数据集分成多个分区
- 每个分区由独立的 worker step 处理
- 适合大规模数据处理

### 4. 作业监听器

在不同生命周期节点执行自定义逻辑：
- `JobExecutionListener`: 作业前后
- `StepExecutionListener`: 步骤前后
- `ChunkListener`: chunk 处理前后
- `ItemReadListener`: 每条数据读取前后
- `ItemProcessListener`: 每条数据处理前后
- `ItemWriteListener`: 每次写入前后

---

## 六、典型应用场景

### 1. 数据迁移
- 从一个数据库迁移到另一个数据库
- 文件格式转换（CSV → 数据库）

### 2. 报表生成
- 定期汇总数据生成报表
- 大批量数据统计分析

### 3. 数据清洗
- 数据验证和清理
- 去重和标准化

### 4. 定时任务
- 每日/每周/每月批处理
- 与其他系统集成

---

## 七、最佳实践

### 1. 性能优化
- **调整 chunk size**: 根据内存和事务开销平衡
- **使用游标而非全量加载**: 避免 OOM
- **批量写入**: 利用数据库批量操作
- **索引优化**: 确保读写操作有合适的索引
- **禁用不必要的日志**: 减少 I/O 开销

### 2. 可靠性设计
- **幂等性**: 确保作业可重复执行
- **检查点**: 合理设置 commit-interval
- **错误处理**: 区分可重试和不可重试异常
- **监控告警**: 集成监控系统

### 3. 可维护性
- **单一职责**: 每个 Step 只做一件事
- **参数化**: 使用 JobParameters 实现灵活性
- **配置外部化**: 避免硬编码
- **文档化**: 记录作业用途和依赖

---

## 八、示例代码

### 基础作业配置

```java
@Configuration
@EnableBatchProcessing
public class BatchConfig {
    
    @Bean
    public Job importUserJob(JobCompletionNotificationListener listener, Step step1) {
        return jobBuilderFactory.get("importUserJob")
            .incrementer(new RunIdIncrementer())
            .listener(listener)
            .flow(step1)
            .end()
            .build();
    }
    
    @Bean
    public Step step1(JdbcBatchItemWriter<User> writer, 
                      FlatFileItemReader<User> reader) {
        return stepBuilderFactory.get("step1")
            .<User, User>chunk(100)
            .reader(reader)
            .processor(new UserItemProcessor())
            .writer(writer)
            .build();
    }
    
    @Bean
    public FlatFileItemReader<User> reader() {
        return new FlatFileItemReaderBuilder<User>()
            .name("userItemReader")
            .resource(new ClassPathResource("users.csv"))
            .delimited()
            .names(new String[]{"name", "email", "age"})
            .fieldSetMapper(new BeanWrapperFieldSetMapper<User>() {{
                setTargetType(User.class);
            }})
            .build();
    }
    
    @Bean
    public JdbcBatchItemWriter<User> writer(DataSource dataSource) {
        return new JdbcBatchItemWriterBuilder<User>()
            .dataSource(dataSource)
            .sql("INSERT INTO users (name, email, age) VALUES (:name, :email, :age)")
            .beanMapped()
            .build();
    }
}
```

---

## 九、总结

Spring Batch 的核心工作原理可以概括为：

1. **分层架构**: Job → Step → Chunk 的三层结构
2. **Chunk 处理**: 读-处理-写的循环，按批次提交事务
3. **状态管理**: 通过 JobRepository 持久化执行状态，支持重启
4. **事务保证**: 每个 chunk 在一个事务中，确保数据一致性
5. **容错机制**: 重试、跳过、监听器等提供强大的错误处理能力
6. **扩展性**: 支持并行处理、分区等高性能场景

Spring Batch 特别适合处理**大量数据**、**需要事务保证**、**可能需要重启**的批处理场景。
