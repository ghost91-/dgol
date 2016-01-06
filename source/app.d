import window;
import std.random : uniform;
import std.conv : to;
import std.algorithm : map, sum;
import std.range : enumerate;
import std.string : format;
import core.thread : Thread, dur;

size_t mod(ptrdiff_t x, size_t n)
{
    while (x < 0)
        x += n;
    return x % n;
}

auto createRandomPopulation(uint y, uint x)
{
    static struct rangeResult
    {
    private:
        bool[][] cells;
        uint y, x;

    public:
        this(uint y, uint x)
        {
            this.y = y;
            this.x = x;
            cells.length = y;
            foreach (ref row; cells)
                row.length = x;

            foreach (uint i, ref row; cells)
                foreach (uint j, ref cell; row)
                    cell = uniform(0, 2).to!bool;
        }

        immutable bool empty = false;

        bool[][] front() @property pure @nogc nothrow
        {
            assert(!empty);
            return cells;
        }

        void popFront()
        {
            assert(!empty);
            int[][] neighbours;
            uint numberOfNeighboursAlive;
            auto newCells = cells.dup;
            foreach (ref row; newCells)
                row = row.dup;
            foreach (int i, row; cells)
            {
                foreach (int j, cell; row)
                {
                    neighbours = [[i - 1, j - 1], [i - 1, j], [i - 1, j + 1], [i,
                        j - 1], [i, j + 1], [i + 1, j - 1], [i + 1, j], [i + 1, j + 1]];
                    numberOfNeighboursAlive = neighbours.map!(
                        neighbour => cells[neighbour[0].mod(y)][neighbour[1].mod(x)]).sum();
                    switch (numberOfNeighboursAlive)
                    {
                    case 2:
                        newCells[i][j] = cells[i][j];
                        break;
                    case 3:
                        newCells[i][j] = 1;
                        break;
                    default:
                        newCells[i][j] = 0;
                        break;
                    }
                }
            }
            cells = newCells;
        }
    }

    return rangeResult(y, x);
}

void main()
{
    auto population = createRandomPopulation(mainWindow.maxY, mainWindow.maxX + 1);
    foreach (a; population.enumerate)
    {
        mainWindow.clear();
        a.value.print();
        mainWindow.movePrint(0, 0, "Generation %s".format(a.index));
        mainWindow.update();
        Thread.sleep(dur!("msecs")(20));
    }
}

void print(bool[][] cells)
{
    foreach (uint i, row; cells)
    {
        foreach (uint j, cell; row)
        {
            if (cell)
            {
                try
                {
                    mainWindow.movePrint(i + 1, j, "x");
                }
                catch (cursorOutOfWindowException e)
                {

                }
            }
        }
    }
}
