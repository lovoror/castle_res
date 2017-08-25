using System;
using System.IO;
using System.Collections.Generic;

namespace TexturePacker {
    public class Settings {
        public bool pot = true;
        public int paddingX = 2, paddingY = 2;
        public bool edgePadding = true;
        public bool duplicatePadding = false;
        public bool rotation;
        public int minWidth = 16, minHeight = 16;
        public int maxWidth = 1024, maxHeight = 1024;
        public bool square = false;
        public bool stripWhitespaceX, stripWhitespaceY;
        public int alphaThreshold;
        //public TextureFilter filterMin = TextureFilter.Nearest, filterMag = TextureFilter.Nearest;
        //public TextureWrap wrapX = TextureWrap.ClampToEdge, wrapY = TextureWrap.ClampToEdge;
        //public Format format = Format.RGBA8888;
        public bool alias = true;
        public string outputFormat = "png";
        public float jpegQuality = 0.9f;
        public bool ignoreBlankImages = true;
        public bool fast;
        public bool debug;
        public bool silent;
        public bool combineSubdirectories;
        public bool flattenPaths;
        public bool premultiplyAlpha;
        public bool useIndexes = true;
        public bool bleed = true;
        public bool limitMemory = true;
        public bool grid;
        public float[] scale = { 1 };
        public string[] scaleSuffix = { "" };
        public string atlasExtension = ".atlas";

        public Settings() {
        }

        public Settings(Settings settings) {
            fast = settings.fast;
            rotation = settings.rotation;
            pot = settings.pot;
            minWidth = settings.minWidth;
            minHeight = settings.minHeight;
            maxWidth = settings.maxWidth;
            maxHeight = settings.maxHeight;
            paddingX = settings.paddingX;
            paddingY = settings.paddingY;
            edgePadding = settings.edgePadding;
            duplicatePadding = settings.duplicatePadding;
            alphaThreshold = settings.alphaThreshold;
            ignoreBlankImages = settings.ignoreBlankImages;
            stripWhitespaceX = settings.stripWhitespaceX;
            stripWhitespaceY = settings.stripWhitespaceY;
            alias = settings.alias;
            //format = settings.format;
            jpegQuality = settings.jpegQuality;
            outputFormat = settings.outputFormat;
            //filterMin = settings.filterMin;
            //filterMag = settings.filterMag;
            //wrapX = settings.wrapX;
            //wrapY = settings.wrapY;
            debug = settings.debug;
            silent = settings.silent;
            combineSubdirectories = settings.combineSubdirectories;
            flattenPaths = settings.flattenPaths;
            premultiplyAlpha = settings.premultiplyAlpha;
            square = settings.square;
            useIndexes = settings.useIndexes;
            bleed = settings.bleed;
            limitMemory = settings.limitMemory;
            grid = settings.grid;
            scale = settings.scale;
            scaleSuffix = settings.scaleSuffix;
            atlasExtension = settings.atlasExtension;
        }

        public string getScaledPackFileName(string packFileName, int scaleIndex) {
            // Use suffix if not empty string.
            if (scaleSuffix[scaleIndex].Length > 0)
                packFileName += scaleSuffix[scaleIndex];
            else {
                // Otherwise if scale != 1 or multiple scales, use subdirectory.
                float scaleValue = scale[scaleIndex];
                if (scale.Length != 1) {
                    packFileName = (scaleValue == (int)scaleValue ? (int)scaleValue : scaleValue)
                        + "/" + packFileName;
                }
            }
            return packFileName;
        }
    }

    public class Alias {
        public string name;
        public int index;
        public int[] splits;
        public int[] pads;
        public int offsetX, offsetY, originalWidth, originalHeight;

        public Alias(Rect rect) {
            name = rect.name;
            index = rect.index;
            splits = rect.splits;
            pads = rect.pads;
            offsetX = rect.offsetX;
            offsetY = rect.offsetY;
            originalWidth = rect.originalWidth;
            originalHeight = rect.originalHeight;
        }

        public void apply(Rect rect) {
            rect.name = name;
            rect.index = index;
            rect.splits = splits;
            rect.pads = pads;
            rect.offsetX = offsetX;
            rect.offsetY = offsetY;
            rect.originalWidth = originalWidth;
            rect.originalHeight = originalHeight;
        }

        /*
        public int compareTo(Alias o) {
            return name.compareTo(o.name);
        }
        */
    }

    public class Rect {
        public string name;
        public int offsetX, offsetY, regionWidth, regionHeight, originalWidth, originalHeight;
        public int x, y;
        public int width, height; // Portion of page taken by this region, including padding.
        public int index;
        public bool rotated;
        public HashSet<Alias> aliases = new HashSet<Alias>();
        public int[] splits;
        public int[] pads;
        public bool canRotate = true;

        private bool isPatch;
        //private BufferedImage image;
        //private File file;
        public int score1, score2;

        /*
        Rect(BufferedImage source, int left, int top, int newWidth, int newHeight, bool isPatch) {
            image = new BufferedImage(source.getColorModel(), source.getRaster().createWritableChild(left, top, newWidth, newHeight,
                0, 0, null), source.getColorModel().isAlphaPremultiplied(), null);
            offsetX = left;
            offsetY = top;
            regionWidth = newWidth;
            regionHeight = newHeight;
            originalWidth = source.getWidth();
            originalHeight = source.getHeight();
            width = newWidth;
            height = newHeight;
            this.isPatch = isPatch;
        }
        */

        /** Clears the image for this rect, which will be loaded from the specified file by {@link #getImage(ImageProcessor)}. */
        /*
        public void unloadImage(File file) {
            this.file = file;
            image = null;
        }
        */

        /*
        public BufferedImage getImage(ImageProcessor imageProcessor) {
            if (image != null) return image;

            BufferedImage image;
            try {
                image = ImageIO.read(file);
            } catch (IOException ex) {
                throw new RuntimeException("Error reading image: " + file, ex);
            }
            if (image == null) throw new RuntimeException("Unable to read image: " + file);
            String name = this.name;
            if (isPatch) name += ".9";
            return imageProcessor.processImage(image, name).getImage(null);
        }
        */

        public Rect() {
        }

        public Rect(Rect rect) {
            x = rect.x;
            y = rect.y;
            width = rect.width;
            height = rect.height;
        }

        public Rect(string name, int width, int height) {
            this.name = name;
            this.width = width;
            this.height = height;
        }

        public void set(Rect rect) {
            name = rect.name;
            //image = rect.image;
            offsetX = rect.offsetX;
            offsetY = rect.offsetY;
            regionWidth = rect.regionWidth;
            regionHeight = rect.regionHeight;
            originalWidth = rect.originalWidth;
            originalHeight = rect.originalHeight;
            x = rect.x;
            y = rect.y;
            width = rect.width;
            height = rect.height;
            index = rect.index;
            rotated = rect.rotated;
            aliases = rect.aliases;
            splits = rect.splits;
            pads = rect.pads;
            canRotate = rect.canRotate;
            score1 = rect.score1;
            score2 = rect.score2;
            //file = rect.file;
            isPatch = rect.isPatch;
        }

        /*
        public int compareTo(Rect o) {
            return name.compareTo(o.name);
        }
        */

        /*
        public bool equals(Object obj) {
            if (this == obj) return true;
            if (obj == null) return false;
            if (getClass() != obj.getClass()) return false;
            Rect other = (Rect)obj;
            if (name == null) {
                if (other.name != null) return false;
            } else if (!name.equals(other.name)) return false;
            return true;
        }
        */

        public string toString() {
            return name + "[" + x + "," + y + " " + width + "x" + height + "]";
        }
        
        static public string getAtlasName(string name, bool flattenPaths) {
            return flattenPaths ? Path.GetFileName(name) : name;
        }
    }

    public class Page {
        public string imageName;
        public List<Rect> outputRects, remainingRects;
        public float occupancy;
        public int x, y, width, height, imageWidth, imageHeight;
    }

    public class MathUtils {
        static public int nextPowerOfTwo(int value) {
            if (value == 0) return 1;
            value--;
            value |= value >> 1;
            value |= value >> 2;
            value |= value >> 4;
            value |= value >> 8;
            value |= value >> 16;
            return value + 1;
        }
    }

    public class BinarySearch {
        int min, max, fuzziness, low, high, current;
        bool pot;

        public BinarySearch(int min, int max, int fuzziness, bool pot) {
            this.pot = pot;
            this.fuzziness = pot ? 0 : fuzziness;
            this.min = pot ? (int)(Math.Log(MathUtils.nextPowerOfTwo(min)) / Math.Log(2)) : min;
            this.max = pot ? (int)(Math.Log(MathUtils.nextPowerOfTwo(max)) / Math.Log(2)) : max;
        }

        public int reset() {
            low = min;
            high = max;
            current = (low + high) >> 1;
            return pot ? (int)Math.Pow(2, current) : current;
        }

        public int next(bool result) {
            if (low >= high) return -1;
            if (result)
                low = current + 1;
            else
                high = current - 1;
            current = (low + high) >> 1;
            if (Math.Abs(low - high) < fuzziness) return -1;
            return pot ? (int)Math.Pow(2, current) : current;
        }
    }

    public class MaxRectsPacker {
        private FreeRectChoiceHeuristic[] methods = getMethods();
        private MaxRects maxRects = new MaxRects();
        private Settings settings;
        //private Sort sort = new Sort();

        private static FreeRectChoiceHeuristic[] getMethods() {
            Array arr = Enum.GetValues(typeof(FreeRectChoiceHeuristic));
            FreeRectChoiceHeuristic[] methods = new FreeRectChoiceHeuristic[arr.Length];
            for (int i = 0; i < arr.Length; i++) {
                methods[i] = (FreeRectChoiceHeuristic)arr.GetValue(i);
            }

            return methods;
        }

        public MaxRectsPacker(Settings settings) {
            this.settings = settings;
            if (settings.minWidth > settings.maxWidth) throw new Exception("Page min width cannot be higher than max width.");
            if (settings.minHeight > settings.maxHeight) throw new Exception("Page min height cannot be higher than max height.");
        }

        public List<Page> pack(List<Rect> inputRects) {
            for (int i = 0, nn = inputRects.Count; i < nn; i++) {
                Rect rect = inputRects[i];
                rect.width += settings.paddingX;
                rect.height += settings.paddingY;
            }

            if (settings.fast) {
                if (settings.rotation) {
                    // Sort by longest side if rotation is enabled.
                    inputRects.Sort(delegate (Rect o1, Rect o2) {
                        int n1 = o1.width > o1.height ? o1.width : o1.height;
                        int n2 = o2.width > o2.height ? o2.width : o2.height;
                        return n2 - n1;
                    });
                } else {
                    // Sort only by width (largest to smallest) if rotation is disabled.
                    inputRects.Sort(delegate (Rect o1, Rect o2) {
                        return o2.width - o1.width;
                    });
                }
            }

            List<Page> pages = new List<Page>();
            while (inputRects.Count > 0) {
                Page result = packPage(inputRects);
                pages.Add(result);
                inputRects = result.remainingRects;
            }
            return pages;
        }

        private Page packPage(List<Rect> inputRects) {
            int paddingX = settings.paddingX, paddingY = settings.paddingY;
            float maxWidth = settings.maxWidth, maxHeight = settings.maxHeight;
            int edgePaddingX = 0, edgePaddingY = 0;
            if (settings.edgePadding) {
                if (settings.duplicatePadding) { // If duplicatePadding, edges get only half padding.
                    maxWidth -= paddingX;
                    maxHeight -= paddingY;
                } else {
                    maxWidth -= paddingX * 2;
                    maxHeight -= paddingY * 2;
                    edgePaddingX = paddingX;
                    edgePaddingY = paddingY;
                }
            }

            // Find min size.
            int minWidth = int.MaxValue, minHeight = int.MaxValue;
            for (int i = 0, nn = inputRects.Count; i < nn; i++) {
                Rect rect = inputRects[i];
                minWidth = Math.Min(minWidth, rect.width);
                minHeight = Math.Min(minHeight, rect.height);
                float width = rect.width - paddingX, height = rect.height - paddingY;
                if (settings.rotation) {
                    if ((width > maxWidth || height > maxHeight) && (width > maxHeight || height > maxWidth)) {
                        string paddingMessage = (edgePaddingX > 0 || edgePaddingY > 0) ? (" and edge padding " + paddingX + "," + paddingY)
                            : "";
                        throw new Exception("Image does not fit with max page size " + settings.maxWidth + "x" + settings.maxHeight
                            + paddingMessage + ": " + rect.name + "[" + width + "," + height + "]");
                    }
                } else {
                    if (width > maxWidth) {
                        string paddingMessage = edgePaddingX > 0 ? (" and X edge padding " + paddingX) : "";
                        throw new Exception("Image does not fit with max page width " + settings.maxWidth + paddingMessage + ": "
                            + rect.name + "[" + width + "," + height + "]");
                    }
                    if (height > maxHeight && (!settings.rotation || width > maxHeight)) {
                        string paddingMessage = edgePaddingY > 0 ? (" and Y edge padding " + paddingY) : "";
                        throw new Exception("Image does not fit in max page height " + settings.maxHeight + paddingMessage + ": "
                            + rect.name + "[" + width + "," + height + "]");
                    }
                }
            }
            minWidth = Math.Max(minWidth, settings.minWidth);
            minHeight = Math.Max(minHeight, settings.minHeight);

            if (!settings.silent) Console.WriteLine("Packing");

            // Find the minimal page size that fits all rects.
            Page bestResult = null;
            if (settings.square) {
                int minSize = Math.Max(minWidth, minHeight);
                int maxSize = Math.Min(settings.maxWidth, settings.maxHeight);
                BinarySearch sizeSearch = new BinarySearch(minSize, maxSize, settings.fast ? 25 : 15, settings.pot);
                int size = sizeSearch.reset(), i = 0;
                while (size != -1) {
                    Page result = packAtSize(true, size - edgePaddingX, size - edgePaddingY, inputRects);
                    if (!settings.silent) {
                        if (++i % 70 == 0) Console.WriteLine("\n");
                        Console.WriteLine(".");
                    }
                    bestResult = getBest(bestResult, result);
                    size = sizeSearch.next(result == null);
                }
                if (!settings.silent) Console.WriteLine("\n");
                // Rects don't fit on one page. Fill a whole page and return.
                if (bestResult == null) bestResult = packAtSize(false, maxSize - edgePaddingX, maxSize - edgePaddingY, inputRects);
                bestResult.outputRects.Sort(rectComparator);
                bestResult.width = Math.Max(bestResult.width, bestResult.height);
                bestResult.height = Math.Max(bestResult.width, bestResult.height);
                return bestResult;
            } else {
                BinarySearch widthSearch = new BinarySearch(minWidth, settings.maxWidth, settings.fast ? 25 : 15, settings.pot);
                BinarySearch heightSearch = new BinarySearch(minHeight, settings.maxHeight, settings.fast ? 25 : 15, settings.pot);
                int width = widthSearch.reset(), i = 0;
                int height = settings.square ? width : heightSearch.reset();
                while (true) {
                    Page bestWidthResult = null;
                    while (width != -1) {
                        Page result = packAtSize(true, width - edgePaddingX, height - edgePaddingY, inputRects);
                        if (!settings.silent) {
                            if (++i % 70 == 0) Console.WriteLine("\n");
                            Console.WriteLine(".");
                        }
                        bestWidthResult = getBest(bestWidthResult, result);
                        width = widthSearch.next(result == null);
                        if (settings.square) height = width;
                    }
                    bestResult = getBest(bestResult, bestWidthResult);
                    if (settings.square) break;
                    height = heightSearch.next(bestWidthResult == null);
                    if (height == -1) break;
                    width = widthSearch.reset();
                }
                if (!settings.silent) Console.WriteLine("\n");
                // Rects don't fit on one page. Fill a whole page and return.
                if (bestResult == null)
                    bestResult = packAtSize(false, settings.maxWidth - edgePaddingX, settings.maxHeight - edgePaddingY, inputRects);
                bestResult.outputRects.Sort(rectComparator);
                return bestResult;
            }
        }

        private int rectComparator(Rect o1, Rect o2) {
            return Rect.getAtlasName(o1.name, settings.flattenPaths).CompareTo(Rect.getAtlasName(o2.name, settings.flattenPaths));
        }

        /** @param fully If true, the only results that pack all rects will be considered. If false, all results are considered, not
	 *           all rects may be packed. */
        private Page packAtSize(bool fully, int width, int height, List<Rect> inputRects) {
            Page bestResult = null;
            for (int i = 0, n = methods.Length; i < n; i++) {
                maxRects.init(width, height, settings);
                Page result;
                if (!settings.fast) {
                    result = maxRects.pack(inputRects, methods[i]);
                } else {
                    List<Rect> remaining = new List<Rect>();
                    for (int ii = 0, nn = inputRects.Count; ii < nn; ii++) {
                        Rect rect = inputRects[ii];
                        if (maxRects.insert(rect, methods[i]) == null) {
                            while (ii < nn)
                                remaining.Add(inputRects[ii++]);
                        }
                    }
                    result = maxRects.getResult();
                    result.remainingRects = remaining;
                }
                if (fully && result.remainingRects.Count > 0) continue;
                if (result.outputRects.Count == 0) continue;
                bestResult = getBest(bestResult, result);
            }
            return bestResult;
        }

        private Page getBest(Page result1, Page result2) {
            if (result1 == null) return result2;
            if (result2 == null) return result1;
            return result1.occupancy > result2.occupancy ? result1 : result2;
        }
    }

    /** Maximal rectangles bin packing algorithm. Adapted from this C++ public domain source:
	 * http://clb.demon.fi/projects/even-more-rectangle-bin-packing
	 * @author Jukka Jyl�nki
	 * @author Nathan Sweet */
    public class MaxRects {
        private int binWidth;
        private int binHeight;
        private List<Rect> usedRectangles = new List<Rect>();
        private List<Rect> freeRectangles = new List<Rect>();
        private Settings settings;

        public void init(int width, int height, Settings settings) {
            binWidth = width;
            binHeight = height;
            this.settings = settings;

            usedRectangles.Clear();
            freeRectangles.Clear();
            Rect n = new Rect();
            n.x = 0;
            n.y = 0;
            n.width = width;
            n.height = height;
            freeRectangles.Add(n);
        }

        /** Packs a single image. Order is defined externally. */
        public Rect insert(Rect rect, FreeRectChoiceHeuristic method) {
            Rect newNode = scoreRect(rect, method);
            if (newNode.height == 0) return null;

            int numRectanglesToProcess = freeRectangles.Count;
            for (int i = 0; i < numRectanglesToProcess; ++i) {
                if (splitFreeNode(freeRectangles[i], newNode)) {
                    freeRectangles.RemoveAt(i);
                    --i;
                    --numRectanglesToProcess;
                }
            }

            pruneFreeList();

            Rect bestNode = new Rect();
            bestNode.set(rect);
            bestNode.score1 = newNode.score1;
            bestNode.score2 = newNode.score2;
            bestNode.x = newNode.x;
            bestNode.y = newNode.y;
            bestNode.width = newNode.width;
            bestNode.height = newNode.height;
            bestNode.rotated = newNode.rotated;

            usedRectangles.Add(bestNode);
            return bestNode;
        }

        /** For each rectangle, packs each one then chooses the best and packs that. Slow! */
        public Page pack(List<Rect> rects, FreeRectChoiceHeuristic method) {
            rects = new List<Rect>(rects);
            while (rects.Count > 0) {
                int bestRectIndex = -1;
                Rect bestNode = new Rect();
                bestNode.score1 = int.MaxValue;
                bestNode.score2 = int.MaxValue;

                // Find the next rectangle that packs best.
                for (int i = 0; i < rects.Count; i++) {
                    Rect newNode = scoreRect(rects[i], method);
                    if (newNode.score1 < bestNode.score1 || (newNode.score1 == bestNode.score1 && newNode.score2 < bestNode.score2)) {
                        bestNode.set(rects[i]);
                        bestNode.score1 = newNode.score1;
                        bestNode.score2 = newNode.score2;
                        bestNode.x = newNode.x;
                        bestNode.y = newNode.y;
                        bestNode.width = newNode.width;
                        bestNode.height = newNode.height;
                        bestNode.rotated = newNode.rotated;
                        bestRectIndex = i;
                    }
                }

                if (bestRectIndex == -1) break;

                placeRect(bestNode);
                rects.RemoveAt(bestRectIndex);
            }

            Page result = getResult();
            result.remainingRects = rects;
            return result;
        }

        public Page getResult() {
            int w = 0, h = 0;
            for (int i = 0; i < usedRectangles.Count; i++) {
                Rect rect = usedRectangles[i];
                w = Math.Max(w, rect.x + rect.width);
                h = Math.Max(h, rect.y + rect.height);
            }
            Page result = new Page();
            result.outputRects = new List<Rect>(usedRectangles);
            result.occupancy = getOccupancy();
            result.width = w;
            result.height = h;
            return result;
        }

        private void placeRect(Rect node) {
            int numRectanglesToProcess = freeRectangles.Count;
            for (int i = 0; i < numRectanglesToProcess; i++) {
                if (splitFreeNode(freeRectangles[i], node)) {
                    freeRectangles.RemoveAt(i);
                    --i;
                    --numRectanglesToProcess;
                }
            }

            pruneFreeList();

            usedRectangles.Add(node);
        }

        private Rect scoreRect(Rect rect, FreeRectChoiceHeuristic method) {
            int width = rect.width;
            int height = rect.height;
            int rotatedWidth = height - settings.paddingY + settings.paddingX;
            int rotatedHeight = width - settings.paddingX + settings.paddingY;
            bool rotate = rect.canRotate && settings.rotation;

            Rect newNode = null;
            switch (method) {
                case FreeRectChoiceHeuristic.BestShortSideFit:
                    newNode = findPositionForNewNodeBestShortSideFit(width, height, rotatedWidth, rotatedHeight, rotate);
                    break;
                case FreeRectChoiceHeuristic.BottomLeftRule:
                    newNode = findPositionForNewNodeBottomLeft(width, height, rotatedWidth, rotatedHeight, rotate);
                    break;
                case FreeRectChoiceHeuristic.ContactPointRule:
                    newNode = findPositionForNewNodeContactPoint(width, height, rotatedWidth, rotatedHeight, rotate);
                    newNode.score1 = -newNode.score1; // Reverse since we are minimizing, but for contact point score bigger is better.
                    break;
                case FreeRectChoiceHeuristic.BestLongSideFit:
                    newNode = findPositionForNewNodeBestLongSideFit(width, height, rotatedWidth, rotatedHeight, rotate);
                    break;
                case FreeRectChoiceHeuristic.BestAreaFit:
                    newNode = findPositionForNewNodeBestAreaFit(width, height, rotatedWidth, rotatedHeight, rotate);
                    break;
            }

            // Cannot fit the current rectangle.
            if (newNode.height == 0) {
                newNode.score1 = int.MaxValue;
                newNode.score2 = int.MaxValue;
            }

            return newNode;
        }

        // / Computes the ratio of used surface area.
        private float getOccupancy() {
            int usedSurfaceArea = 0;
            for (int i = 0; i < usedRectangles.Count; i++)
                usedSurfaceArea += usedRectangles[i].width * usedRectangles[i].height;
            return (float)usedSurfaceArea / (binWidth * binHeight);
        }

        private Rect findPositionForNewNodeBottomLeft(int width, int height, int rotatedWidth, int rotatedHeight, bool rotate) {
            Rect bestNode = new Rect();

            bestNode.score1 = int.MaxValue; // best y, score2 is best x

            for (int i = 0; i < freeRectangles.Count; i++) {
                // Try to place the rectangle in upright (non-rotated) orientation.
                if (freeRectangles[i].width >= width && freeRectangles[i].height >= height) {
                    int topSideY = freeRectangles[i].y + height;
                    if (topSideY < bestNode.score1 || (topSideY == bestNode.score1 && freeRectangles[i].x < bestNode.score2)) {
                        bestNode.x = freeRectangles[i].x;
                        bestNode.y = freeRectangles[i].y;
                        bestNode.width = width;
                        bestNode.height = height;
                        bestNode.score1 = topSideY;
                        bestNode.score2 = freeRectangles[i].x;
                        bestNode.rotated = false;
                    }
                }
                if (rotate && freeRectangles[i].width >= rotatedWidth && freeRectangles[i].height >= rotatedHeight) {
                    int topSideY = freeRectangles[i].y + rotatedHeight;
                    if (topSideY < bestNode.score1 || (topSideY == bestNode.score1 && freeRectangles[i].x < bestNode.score2)) {
                        bestNode.x = freeRectangles[i].x;
                        bestNode.y = freeRectangles[i].y;
                        bestNode.width = rotatedWidth;
                        bestNode.height = rotatedHeight;
                        bestNode.score1 = topSideY;
                        bestNode.score2 = freeRectangles[i].x;
                        bestNode.rotated = true;
                    }
                }
            }
            return bestNode;
        }

        private Rect findPositionForNewNodeBestShortSideFit(int width, int height, int rotatedWidth, int rotatedHeight, bool rotate) {
            Rect bestNode = new Rect();
            bestNode.score1 = int.MaxValue;

            for (int i = 0; i < freeRectangles.Count; i++) {
                // Try to place the rectangle in upright (non-rotated) orientation.
                if (freeRectangles[i].width >= width && freeRectangles[i].height >= height) {
                    int leftoverHoriz = Math.Abs(freeRectangles[i].width - width);
                    int leftoverVert = Math.Abs(freeRectangles[i].height - height);
                    int shortSideFit = Math.Min(leftoverHoriz, leftoverVert);
                    int longSideFit = Math.Max(leftoverHoriz, leftoverVert);

                    if (shortSideFit < bestNode.score1 || (shortSideFit == bestNode.score1 && longSideFit < bestNode.score2)) {
                        bestNode.x = freeRectangles[i].x;
                        bestNode.y = freeRectangles[i].y;
                        bestNode.width = width;
                        bestNode.height = height;
                        bestNode.score1 = shortSideFit;
                        bestNode.score2 = longSideFit;
                        bestNode.rotated = false;
                    }
                }

                if (rotate && freeRectangles[i].width >= rotatedWidth && freeRectangles[i].height >= rotatedHeight) {
                    int flippedLeftoverHoriz = Math.Abs(freeRectangles[i].width - rotatedWidth);
                    int flippedLeftoverVert = Math.Abs(freeRectangles[i].height - rotatedHeight);
                    int flippedShortSideFit = Math.Min(flippedLeftoverHoriz, flippedLeftoverVert);
                    int flippedLongSideFit = Math.Max(flippedLeftoverHoriz, flippedLeftoverVert);

                    if (flippedShortSideFit < bestNode.score1
                        || (flippedShortSideFit == bestNode.score1 && flippedLongSideFit < bestNode.score2)) {
                        bestNode.x = freeRectangles[i].x;
                        bestNode.y = freeRectangles[i].y;
                        bestNode.width = rotatedWidth;
                        bestNode.height = rotatedHeight;
                        bestNode.score1 = flippedShortSideFit;
                        bestNode.score2 = flippedLongSideFit;
                        bestNode.rotated = true;
                    }
                }
            }

            return bestNode;
        }

        private Rect findPositionForNewNodeBestLongSideFit(int width, int height, int rotatedWidth, int rotatedHeight,
            bool rotate) {
            Rect bestNode = new Rect();

            bestNode.score2 = int.MaxValue;

            for (int i = 0; i < freeRectangles.Count; i++) {
                // Try to place the rectangle in upright (non-rotated) orientation.
                if (freeRectangles[i].width >= width && freeRectangles[i].height >= height) {
                    int leftoverHoriz = Math.Abs(freeRectangles[i].width - width);
                    int leftoverVert = Math.Abs(freeRectangles[i].height - height);
                    int shortSideFit = Math.Min(leftoverHoriz, leftoverVert);
                    int longSideFit = Math.Max(leftoverHoriz, leftoverVert);

                    if (longSideFit < bestNode.score2 || (longSideFit == bestNode.score2 && shortSideFit < bestNode.score1)) {
                        bestNode.x = freeRectangles[i].x;
                        bestNode.y = freeRectangles[i].y;
                        bestNode.width = width;
                        bestNode.height = height;
                        bestNode.score1 = shortSideFit;
                        bestNode.score2 = longSideFit;
                        bestNode.rotated = false;
                    }
                }

                if (rotate && freeRectangles[i].width >= rotatedWidth && freeRectangles[i].height >= rotatedHeight) {
                    int leftoverHoriz = Math.Abs(freeRectangles[i].width - rotatedWidth);
                    int leftoverVert = Math.Abs(freeRectangles[i].height - rotatedHeight);
                    int shortSideFit = Math.Min(leftoverHoriz, leftoverVert);
                    int longSideFit = Math.Max(leftoverHoriz, leftoverVert);

                    if (longSideFit < bestNode.score2 || (longSideFit == bestNode.score2 && shortSideFit < bestNode.score1)) {
                        bestNode.x = freeRectangles[i].x;
                        bestNode.y = freeRectangles[i].y;
                        bestNode.width = rotatedWidth;
                        bestNode.height = rotatedHeight;
                        bestNode.score1 = shortSideFit;
                        bestNode.score2 = longSideFit;
                        bestNode.rotated = true;
                    }
                }
            }
            return bestNode;
        }

        private Rect findPositionForNewNodeBestAreaFit(int width, int height, int rotatedWidth, int rotatedHeight,
            bool rotate) {
            Rect bestNode = new Rect();

            bestNode.score1 = int.MaxValue; // best area fit, score2 is best short side fit

            for (int i = 0; i < freeRectangles.Count; i++) {
                int areaFit = freeRectangles[i].width * freeRectangles[i].height - width * height;

                // Try to place the rectangle in upright (non-rotated) orientation.
                if (freeRectangles[i].width >= width && freeRectangles[i].height >= height) {
                    int leftoverHoriz = Math.Abs(freeRectangles[i].width - width);
                    int leftoverVert = Math.Abs(freeRectangles[i].height - height);
                    int shortSideFit = Math.Min(leftoverHoriz, leftoverVert);

                    if (areaFit < bestNode.score1 || (areaFit == bestNode.score1 && shortSideFit < bestNode.score2)) {
                        bestNode.x = freeRectangles[i].x;
                        bestNode.y = freeRectangles[i].y;
                        bestNode.width = width;
                        bestNode.height = height;
                        bestNode.score2 = shortSideFit;
                        bestNode.score1 = areaFit;
                        bestNode.rotated = false;
                    }
                }

                if (rotate && freeRectangles[i].width >= rotatedWidth && freeRectangles[i].height >= rotatedHeight) {
                    int leftoverHoriz = Math.Abs(freeRectangles[i].width - rotatedWidth);
                    int leftoverVert = Math.Abs(freeRectangles[i].height - rotatedHeight);
                    int shortSideFit = Math.Min(leftoverHoriz, leftoverVert);

                    if (areaFit < bestNode.score1 || (areaFit == bestNode.score1 && shortSideFit < bestNode.score2)) {
                        bestNode.x = freeRectangles[i].x;
                        bestNode.y = freeRectangles[i].y;
                        bestNode.width = rotatedWidth;
                        bestNode.height = rotatedHeight;
                        bestNode.score2 = shortSideFit;
                        bestNode.score1 = areaFit;
                        bestNode.rotated = true;
                    }
                }
            }
            return bestNode;
        }

        // / Returns 0 if the two intervals i1 and i2 are disjoint, or the length of their overlap otherwise.
        private int commonIntervalLength(int i1start, int i1end, int i2start, int i2end) {
            if (i1end < i2start || i2end < i1start) return 0;
            return Math.Min(i1end, i2end) - Math.Max(i1start, i2start);
        }

        private int contactPointScoreNode(int x, int y, int width, int height) {
            int score = 0;

            if (x == 0 || x + width == binWidth) score += height;
            if (y == 0 || y + height == binHeight) score += width;

            List<Rect> usedRectangles = this.usedRectangles;
            for (int i = 0, n = usedRectangles.Count; i < n; i++) {
                Rect rect = usedRectangles[i];
                if (rect.x == x + width || rect.x + rect.width == x)
                    score += commonIntervalLength(rect.y, rect.y + rect.height, y, y + height);
                if (rect.y == y + height || rect.y + rect.height == y)
                    score += commonIntervalLength(rect.x, rect.x + rect.width, x, x + width);
            }
            return score;
        }

        private Rect findPositionForNewNodeContactPoint(int width, int height, int rotatedWidth, int rotatedHeight,
            bool rotate) {

            Rect bestNode = new Rect();
            bestNode.score1 = -1; // best contact score

            List<Rect> freeRectangles = this.freeRectangles;
            for (int i = 0, n = freeRectangles.Count; i < n; i++) {
                // Try to place the rectangle in upright (non-rotated) orientation.
                Rect free = freeRectangles[i];
                if (free.width >= width && free.height >= height) {
                    int score = contactPointScoreNode(free.x, free.y, width, height);
                    if (score > bestNode.score1) {
                        bestNode.x = free.x;
                        bestNode.y = free.y;
                        bestNode.width = width;
                        bestNode.height = height;
                        bestNode.score1 = score;
                        bestNode.rotated = false;
                    }
                }
                if (rotate && free.width >= rotatedWidth && free.height >= rotatedHeight) {
                    int score = contactPointScoreNode(free.x, free.y, rotatedWidth, rotatedHeight);
                    if (score > bestNode.score1) {
                        bestNode.x = free.x;
                        bestNode.y = free.y;
                        bestNode.width = rotatedWidth;
                        bestNode.height = rotatedHeight;
                        bestNode.score1 = score;
                        bestNode.rotated = true;
                    }
                }
            }
            return bestNode;
        }

        private bool splitFreeNode(Rect freeNode, Rect usedNode) {
            // Test with SAT if the rectangles even intersect.
            if (usedNode.x >= freeNode.x + freeNode.width || usedNode.x + usedNode.width <= freeNode.x
                || usedNode.y >= freeNode.y + freeNode.height || usedNode.y + usedNode.height <= freeNode.y) return false;

            if (usedNode.x < freeNode.x + freeNode.width && usedNode.x + usedNode.width > freeNode.x) {
                // New node at the top side of the used node.
                if (usedNode.y > freeNode.y && usedNode.y < freeNode.y + freeNode.height) {
                    Rect newNode = new Rect(freeNode);
                    newNode.height = usedNode.y - newNode.y;
                    freeRectangles.Add(newNode);
                }

                // New node at the bottom side of the used node.
                if (usedNode.y + usedNode.height < freeNode.y + freeNode.height) {
                    Rect newNode = new Rect(freeNode);
                    newNode.y = usedNode.y + usedNode.height;
                    newNode.height = freeNode.y + freeNode.height - (usedNode.y + usedNode.height);
                    freeRectangles.Add(newNode);
                }
            }

            if (usedNode.y < freeNode.y + freeNode.height && usedNode.y + usedNode.height > freeNode.y) {
                // New node at the left side of the used node.
                if (usedNode.x > freeNode.x && usedNode.x < freeNode.x + freeNode.width) {
                    Rect newNode = new Rect(freeNode);
                    newNode.width = usedNode.x - newNode.x;
                    freeRectangles.Add(newNode);
                }

                // New node at the right side of the used node.
                if (usedNode.x + usedNode.width < freeNode.x + freeNode.width) {
                    Rect newNode = new Rect(freeNode);
                    newNode.x = usedNode.x + usedNode.width;
                    newNode.width = freeNode.x + freeNode.width - (usedNode.x + usedNode.width);
                    freeRectangles.Add(newNode);
                }
            }

            return true;
        }

        private void pruneFreeList() {
            /*
			 * /// Would be nice to do something like this, to avoid a Theta(n^2) loop through each pair. /// But unfortunately it
			 * doesn't quite cut it, since we also want to detect containment. /// Perhaps there's another way to do this faster than
			 * Theta(n^2).
			 * 
			 * if (freeRectangles.Count > 0) clb::sort::QuickSort(&freeRectangles[0], freeRectangles.Count, NodeSortCmp);
			 * 
			 * for(int i = 0; i < freeRectangles.Count-1; i++) if (freeRectangles[i].x == freeRectangles[i+1].x && freeRectangles[i].y
			 * == freeRectangles[i+1].y && freeRectangles[i].width == freeRectangles[i+1].width && freeRectangles[i].height ==
			 * freeRectangles[i+1].height) { freeRectangles.erase(freeRectangles.begin() + i); --i; }
			 */

            // Go through each pair and remove any rectangle that is redundant.
            List<Rect> freeRectangles = this.freeRectangles;
            for (int i = 0, n = freeRectangles.Count; i < n; i++)
                for (int j = i + 1; j < n; ++j) {
                    Rect rect1 = freeRectangles[i];
                    Rect rect2 = freeRectangles[j];
                    if (isContainedIn(rect1, rect2)) {
                        freeRectangles.RemoveAt(i);
                        --i;
                        --n;
                        break;
                    }
                    if (isContainedIn(rect2, rect1)) {
                        freeRectangles.RemoveAt(j);
                        --j;
                        --n;
                    }
                }
        }

        private bool isContainedIn(Rect a, Rect b) {
            return a.x >= b.x && a.y >= b.y && a.x + a.width <= b.x + b.width && a.y + a.height <= b.y + b.height;
        }
    }

    public enum FreeRectChoiceHeuristic {
        // BSSF: Positions the rectangle against the short side of a free rectangle into which it fits the best.
        BestShortSideFit,
        // BLSF: Positions the rectangle against the long side of a free rectangle into which it fits the best.
        BestLongSideFit,
        // BAF: Positions the rectangle into the smallest free rect into which it fits.
        BestAreaFit,
        // BL: Does the Tetris placement.
        BottomLeftRule,
        // CP: Choosest the placement where the rectangle touches other rects as much as possible.
        ContactPointRule
    };
}
