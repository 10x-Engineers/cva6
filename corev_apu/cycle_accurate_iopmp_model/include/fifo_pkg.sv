package fifo_pkg;

    typedef struct {
      int MAX_DEPTH;
      int size;
      int head;
      int tail;
      logic [31:0] [4095:0] data; // static allocation, replace 1024 with max depth
    } fifo_t;

    function void init(ref fifo_t f, input logic [31:0] depth);
      f.MAX_DEPTH = depth;
      f.size      = 0;
      f.head      = 0;
      f.tail      = 0;
    endfunction

    function void push(ref fifo_t f, input logic [4095:0] d);
      // if (f.size < f.MAX_DEPTH) begin
        f.data[f.tail] = d;
        f.tail = (f.tail + 1) % f.MAX_DEPTH;
        f.size++;
      // end
    endfunction

    function bit pop(ref fifo_t f, output logic [4095:0] d);
      if (f.size > 0) begin
        d = f.data[f.head];
        f.head = (f.head + 1) % f.MAX_DEPTH;
        f.size--;
        return 1;
      end
      d = '0;
      return 0;
    endfunction

    // --------------------------
    // peek()
    // --------------------------
    function bit peek(ref fifo_t f, output logic [91:0] d);
      if (f.size > 0) begin
        d = f.data[f.head];
        return 1;
      end
      d = '0;
      return 0;
    endfunction


    // --------------------------
    // discard_n()
    // --------------------------
    task discard_n(ref fifo_t f, input logic [31:0] n);
      if (n <= 0) return;

      if (n >= f.size) begin
        f.size = 0;
        f.head = 0;
        f.tail = 0;
      end
      else begin
        f.head = (f.head + n) % f.MAX_DEPTH;
        f.size -= n;
      end
    endtask


    // --------------------------
    // is_empty()
    // --------------------------
    function bit is_empty(fifo_t f);
      return (f.size == 0);
    endfunction


    // --------------------------
    // is_full()
    // --------------------------
    function bit is_full(fifo_t f);
      return (f.size == f.MAX_DEPTH);
    endfunction


    // --------------------------
    // size()
    // --------------------------
    function int size(fifo_t f);
      return f.size;
    endfunction

  endpackage
