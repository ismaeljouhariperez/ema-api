class CreateSolidQueueTables < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_queue_jobs do |t|
      t.string :queue_name, null: false
      t.string :class_name, null: false
      t.text :arguments
      t.integer :priority, default: 0, null: false
      t.string :active_job_id
      t.datetime :scheduled_at
      t.datetime :finished_at
      t.string :concurrency_key

      t.datetime :created_at, null: false

      t.index [:active_job_id], name: "index_solid_queue_jobs_on_active_job_id"
      t.index [:class_name], name: "index_solid_queue_jobs_on_class_name"
      t.index [:finished_at], name: "index_solid_queue_jobs_on_finished_at"
      t.index [:queue_name, :finished_at], name: "index_solid_queue_jobs_for_filtering"
      t.index [:scheduled_at], name: "index_solid_queue_jobs_on_scheduled_at"
    end

    create_table :solid_queue_semaphores do |t|
      t.string :key, null: false
      t.integer :value, default: 1, null: false
      t.datetime :expires_at, null: false

      t.index [:key, :value], name: "index_solid_queue_semaphores_on_key_and_value"
      t.index [:expires_at], name: "index_solid_queue_semaphores_on_expires_at"
    end

    create_table :solid_queue_blocked_executions do |t|
      t.references :job, null: false, foreign_key: { to_table: :solid_queue_jobs }
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.string :concurrency_key, null: false
      t.datetime :expires_at, null: false

      t.index [:concurrency_key, :priority, :job_id], name: "index_solid_queue_blocked_executions_for_release"
      t.index [:expires_at], name: "index_solid_queue_blocked_executions_on_expires_at"
    end

    create_table :solid_queue_ready_executions do |t|
      t.references :job, null: false, foreign_key: { to_table: :solid_queue_jobs }
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false

      t.index [:priority, :job_id], name: "index_solid_queue_ready_executions_for_pop"
      t.index [:queue_name, :priority, :job_id], name: "index_solid_queue_ready_executions_for_pop_in_queue"
    end

    create_table :solid_queue_claimed_executions do |t|
      t.references :job, null: false, foreign_key: { to_table: :solid_queue_jobs }
      t.bigint :process_id
      t.datetime :created_at, null: false

      t.index [:process_id, :job_id], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
    end

    create_table :solid_queue_processes do |t|
      t.string :kind, null: false
      t.datetime :last_heartbeat_at, null: false
      t.bigint :supervisor_id

      t.index [:last_heartbeat_at], name: "index_solid_queue_processes_on_last_heartbeat_at"
      t.index [:supervisor_id], name: "index_solid_queue_processes_on_supervisor_id"
    end

    create_table :solid_queue_pauses do |t|
      t.string :queue_name, null: false
      t.datetime :created_at, null: false

      t.index [:queue_name], name: "index_solid_queue_pauses_on_queue_name", unique: true
    end
  end
end 