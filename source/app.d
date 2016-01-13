import window;
import std.random : uniform;
import std.conv : to;
import std.algorithm : map, sum;
import std.range : enumerate;
import std.string : format;
import core.thread : Thread, dur;

size_t mod(ptrdiff_t x, in size_t n) @nogc nothrow pure
{
    while (x < 0)
        x += n;
    return x % n;
}

auto createRandomPopulation(in uint y, in uint x)
{
    static struct rangeResult
    {
    private:
        bool[][] population;
        uint y, x;

    public:
        this(uint y, uint x)
        {
            this.y = y;
            this.x = x;
            population.length = y;
            foreach (ref row; population)
                row.length = x;

            foreach (uint i, ref row; population)
                foreach (uint j, ref cell; row)
                    cell = uniform(0, 2).to!bool;
        }

        immutable bool empty = false;

        bool[][] front() @property pure @nogc nothrow
        {
            assert(!empty);
            return population;
        }

        void popFront()
        {
            assert(!empty);
            int[][] neighbours;
            uint numberOfNeighboursAlive;
            auto newpopulation = population.dup;
            foreach (ref row; newpopulation)
                row = row.dup;
            foreach (int i, row; population)
            {
                foreach (int j, cell; row)
                {
                    neighbours = [[i - 1, j - 1], [i - 1, j], [i - 1, j + 1], [i,
                        j - 1], [i, j + 1], [i + 1, j - 1], [i + 1, j], [i + 1, j + 1]];
                    numberOfNeighboursAlive = neighbours.map!(
                        neighbour => population[neighbour[0].mod(y)][neighbour[1].mod(x)]).sum();
                    switch (numberOfNeighboursAlive)
                    {
                    case 2:
                        newpopulation[i][j] = population[i][j];
                        break;
                    case 3:
                        newpopulation[i][j] = 1;
                        break;
                    default:
                        newpopulation[i][j] = 0;
                        break;
                    }
                }
            }
            population = newpopulation;
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

void print(in bool[][] population)
{
    foreach (uint i, row; population)
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
