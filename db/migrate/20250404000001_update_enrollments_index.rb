class UpdateEnrollmentsIndex < ActiveRecord::Migration[8.0]
  def change
    # Eliminar el índice único existente
    remove_index :enrollments, [:user_id, :course_id]
    
    # Agregar un nuevo índice que incluya el status
    add_index :enrollments, [:user_id, :course_id, :status], unique: true
  end
end