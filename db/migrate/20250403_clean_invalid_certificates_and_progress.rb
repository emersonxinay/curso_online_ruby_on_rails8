class CleanInvalidCertificatesAndProgress < ActiveRecord::Migration[7.0]
  def up
    # Eliminar certificados de usuarios que no están inscritos
    Certificate.where.not(
      user_id: Enrollment.active.select(:user_id)
    ).delete_all

    # Eliminar lecciones completadas de usuarios que no están inscritos
    CompletedLesson.where.not(
      user_id: Enrollment.active.select(:user_id)
    ).delete_all

    # Eliminar certificados de cursos que no están completados
    Certificate.joins(:course)
               .where.not(
                 id: Enrollment.active.joins(:completed_lessons => [:lesson => [:section => :course]])
                                    .group('enrollments.id')
                                    .having('COUNT(DISTINCT lessons.id) = (SELECT COUNT(*) FROM lessons WHERE lessons.section_id IN (SELECT id FROM sections WHERE course_id = enrollments.course_id))')
                                    .select(:course_id)
               ).delete_all

    puts "Limpiado completado:"
    puts "- Certificados de usuarios no inscritos: #{Certificate.where.not(user_id: Enrollment.active.select(:user_id)).count}"
    puts "- Lecciones completadas de usuarios no inscritos: #{CompletedLesson.where.not(user_id: Enrollment.active.select(:user_id)).count}"
    puts "- Certificados de cursos no completados: #{Certificate.joins(:course).where.not(id: Enrollment.active.joins(:completed_lessons => [:lesson => [:section => :course]]).group('enrollments.id').having('COUNT(DISTINCT lessons.id) = (SELECT COUNT(*) FROM lessons WHERE lessons.section_id IN (SELECT id FROM sections WHERE course_id = enrollments.course_id))').select(:course_id)).count}"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "No se puede revertir esta migración ya que solo limpia datos."
  end
end