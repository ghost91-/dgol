import window;
import std.random;
import std.conv;
import std.algorithm;
import std.range;
import std.string;
import core.thread;

auto createRandomPopulation(uint y, uint x)
{
    static struct rangeResult
    {
    private:
        uint[][] cells;
        uint y, x;

        uint isCellAlive(int y, int x)
        {
            if (y < 0 || y >= cells.length || x < 0 || x >= cells[0].length)
                return 0;
            else
                return cells[y][x];
        }

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
                    cell = uniform(0, 2);
        }

        immutable bool empty = false;

        uint[][] front() @property pure @nogc nothrow
        {
            assert(!empty);
            return cells;
        }

        void popFront()
        {
            assert(!empty);
            int[][] neighbours;
            auto newCells = cells.dup;
            foreach (ref row; newCells)
                row = row.dup;
            foreach (int i, row; cells)
            {
                foreach (int j, cell; row)
                {
                    neighbours = [[i - 1, j - 1], [i - 1, j], [i - 1, j + 1], [i,
                        j - 1], [i, j + 1], [i + 1, j - 1], [i + 1, j], [i + 1, j + 1]];
                    uint numberOfNeighboursAlive = neighbours.map!(
                        neighbour => isCellAlive(neighbour[0], neighbour[1])).sum();
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
        Thread.sleep(dur!("msecs")(50));
    }
}

void print(uint[][] cells)
{
    foreach (uint i, row; cells)
        foreach (uint j, cell; row)
        {
            if (cell == 1)
                try
            {
                mainWindow.movePrint(i + 1, j, "x");
            }
            catch (cursorOutOfWindowException e)
            {

            }
        }
    mainWindow.update();
}
