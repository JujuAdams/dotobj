var _old_world = matrix_get(matrix_world); 
matrix_set(matrix_world, matrix_build(350, 150, 0,   0,0,0,   800, 800, 1));
model.Submit();
matrix_set(matrix_world, _old_world);