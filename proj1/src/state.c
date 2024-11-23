#include "state.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_state_t *state, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_state_t *state, unsigned int snum);
static char next_square(game_state_t *state, unsigned int snum);
static void update_tail(game_state_t *state, unsigned int snum);
static void update_head(game_state_t *state, unsigned int snum);

/* Task 1 */
game_state_t *create_default_state() {
  game_state_t *state = malloc(sizeof(game_state_t));
  if (state == NULL) {
    return NULL;
  }
  state->num_rows = 18;
  state->board = malloc(state->num_rows * 20 * sizeof(char));
  if (state->board == NULL) {
    free(state);
    return NULL;
  }
  for (unsigned int i = 0; i < state->num_rows; i++) {
    state->board[i] = malloc(20 * sizeof(char));
    if (state->board[i] == NULL) {
      for (unsigned int j = 0; j < i; j++) {
        free(state->board[j]);
      }
      free(state->board);
      free(state);
      return NULL;
    }
    for (unsigned int j = 0; j < 20; j++) {
      if (i == 0 || j == 0 || i == state->num_rows - 1 || j == 19) {
        set_board_at(state, i, j, '#');
      } else {
        set_board_at(state, i, j, ' ');
    }
  }
  }
  state->num_snakes = 1;
  set_board_at(state, 2, 9, '*');
  set_board_at(state, 2, 2, 'd');
  set_board_at(state, 2, 3, '>');
  set_board_at(state, 2, 4, 'D');

  /*Initialize a snake */
  snake_t *snake = malloc(sizeof(snake_t));
  if (snake == NULL) {
    for (unsigned int i = 0; i < state->num_rows; i++) {
      free(state->board[i]);
    }
    free(state->board);
    free(state);
    return NULL;
  }
  snake->tail_row = 2;
  snake->tail_col = 2;
  snake->head_row = 2;
  snake->head_col = 4;
  snake->live = true;

  state->snakes = snake;

  return state;
}


/* Task 2 */
void free_state(game_state_t *state) {
  for (unsigned int i = 0; i < state->num_rows; i++) {
    free(state->board[i]);
  }
  free(state->board);
  free(state->snakes);
  free(state);
  return;
}

/* Task 3 */
void print_board(game_state_t *state, FILE *fp) {
  for (unsigned int i = 0; i < state->num_rows; i++) {
    fprintf(fp, "%s\n", state->board[i]);
  }
}

/*
  Saves the current state into filename. Does not modify the state object.
  (already implemented for you).
*/
void save_board(game_state_t *state, char *filename) {
  FILE *f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_state_t *state, unsigned int row, unsigned int col) { return state->board[row][col]; }

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_state_t *state, unsigned int row, unsigned int col, char ch) {
  state->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  if (c == 'w' || c == 'a' || c == 's' || c == 'd') {
    return true;
  } else {
    return false;
  }
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  if (c == 'W' || c == 'A' || c == 'S' || c == 'D' || c == 'x') {
    return true;
  } else {
    return false;
  }
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  if (is_tail(c) || is_head(c) || c == '^' || c == '<' || c == 'v' || c == '>') {
    return true;
  }
  return false;
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  if (c == '^') {
    return 'w';
  } else if (c == '<') {
    return 'a';
  } else if (c == 'v') {
    return 's';
  } else if (c == '>') {
    return 'd';
  }
  return '?';
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  if (c == 'W') {
    return '^';
  } else if (c == 'A') {
    return '<';
  } else if (c == 'S') {
    return 'v';
  } else if (c == 'D') {
    return '>';
  }
  
  return '?';
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  if (c == 'v' || c == 's' || c == 'S') {
    return cur_row + 1;
  } else if (c == '^' || c == 'w' || c == 'W') {
    return cur_row -1;
  } else {
    return cur_row;
  }  
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  if (c == '>' || c == 'd' || c == 'D') {
    return cur_col + 1;
  } else if (c == '<' || c == 'a' || c == 'A') {
    return cur_col - 1;
  } else {
    return cur_col;
  }
}

/*
  Task 4.2

  Helper function for update_state. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_state_t *state, unsigned int snum) {
  snake_t *snake = state->snakes;
  unsigned int head_col = (snake + snum)->head_col;
  unsigned int head_row = (snake + snum)->head_row;

  unsigned int next_head_col = get_next_col(head_col, get_board_at(state, head_row, head_col));
  unsigned int next_head_row = get_next_row(head_row, get_board_at(state, head_row, head_col));

  return get_board_at(state, next_head_row, next_head_col);
}

/*
  Task 4.3

  Helper function for update_state. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_state_t *state, unsigned int snum) {
  snake_t *snake = state->snakes;
  unsigned int head_col = (snake + snum)->head_col;
  unsigned int head_row = (snake + snum)->head_row;

  char head_char = get_board_at(state, head_row, head_col);
  unsigned int next_head_col = get_next_col(head_col, head_char);
  unsigned int next_head_row = get_next_row(head_row, head_char);

  set_board_at(state, head_row, head_col, head_to_body(head_char));
  set_board_at(state, next_head_row, next_head_col, head_char);

  (snake + snum)->head_col = next_head_col;
  (snake + snum)->head_row = next_head_row;
}

/*
  Task 4.4

  Helper function for update_state. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_state_t *state, unsigned int snum) {
  snake_t *snake = state->snakes;
  unsigned int tail_col = (snake + snum)->tail_col;
  unsigned int tail_row = (snake + snum)->tail_row;

  char tail_char = get_board_at(state, tail_row, tail_col);
  unsigned int next_tail_col = get_next_col(tail_col, tail_char);
  unsigned int next_tail_row = get_next_row(tail_row, tail_char);

  set_board_at(state, tail_row, tail_col, ' ');
  char new_tail_char = body_to_tail(get_board_at(state, next_tail_row, next_tail_col));
  set_board_at(state, next_tail_row, next_tail_col, new_tail_char);

  (snake + snum)->tail_col = next_tail_col;
  (snake + snum)->tail_row = next_tail_row;
}

/* Task 4.5 */
void update_state(game_state_t *state, int (*add_food)(game_state_t *state)) {
  snake_t *snake = state->snakes;
  for (unsigned int i = 0; i < state->num_snakes; i++) {
    char next = next_square(state, i);
    if(is_snake(next) || next == '#') {
      unsigned int head_row = (snake + i)->head_row;
      unsigned int head_col = (snake + i)->head_col;
      (snake + i)->live = false;
      set_board_at(state, head_row, head_col, 'x');
    } else if(next == '*') {
      update_head(state, i);
      add_food(state);
    } else {
      update_tail(state, i);
      update_head(state, i);
    }
  }
  
}

/* Task 5.1 */
char *read_line(FILE *fp) {
  /*If file is empty*/
  if (fp == NULL) {
    return NULL;
  }

  size_t size = 10; /*Buffer size */
  char * line = malloc(size);
  if (line == NULL) {
    return NULL;
  }
  size_t len = 0; /*Actual size*/
  
  while (fgets(line + len, (int)(size - len), fp) != NULL ) {
    len += strlen(line + len); /*Len upgrades by the new appended string len*/

    /*If a complete line is read or reach the end of a file, break*/
    if (line[len - 1] == '\n' || feof(fp)) {
      break;
    }

    /*Else, resize for reading the complete line*/
    else {
      size *= 2;
      char *new_line= realloc(line, size);

      if (new_line == NULL) {
        free(line);
        return NULL;
      }
      line = new_line;
    }
  }

  if (len == 0) {
    free(line);
    return NULL;
  }

  return line;

}

/* Task 5.2 */
game_state_t *load_board(FILE *fp) {
  /*If file is NULL*/
  if (fp == NULL) {
    return NULL;
  }

  unsigned int row_num = 10;
  unsigned int count = 0;

  char **lines = malloc(sizeof(char *) * row_num);
  if (lines == NULL) {
    return NULL;
  }

  char * current_line = read_line(fp); 

  while (current_line != NULL) {
    /*If row_num is not enough*/
    if (count >= row_num) {
      char ** new_lines = realloc(lines, sizeof(char *) * row_num * 2);
      if (new_lines == NULL) {
        for (unsigned i = 0; i < count; i++) {
        free(lines + i);
      }
      free(lines);
      return NULL;
      }
      lines = new_lines;
      row_num *= 2;
    }

    *(lines + count) = current_line;
    count += 1;
    current_line = read_line(fp);
  }

  if (count == 0) {
    free(lines);
    return NULL;
  }
    
  game_state_t *state = malloc(sizeof(game_state_t));
  if (state == NULL) {
    for (unsigned i = 0; i < count; i++) {
      free(lines[i]);
    }
    free(lines);
    return NULL;
  }

  state->board = lines;
  state->num_rows = count;;
  state->num_snakes = 0;
  state->snakes = NULL;

  return state;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_state_t *state, unsigned int snum) {
  // TODO: Implement this function.
  return;
}

/* Task 6.2 */
game_state_t *initialize_snakes(game_state_t *state) {
  // TODO: Implement this function.
  return NULL;
}
