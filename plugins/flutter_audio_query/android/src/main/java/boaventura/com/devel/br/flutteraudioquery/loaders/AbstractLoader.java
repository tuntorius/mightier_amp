package boaventura.com.devel.br.flutteraudioquery.loaders;

import android.content.ContentResolver;
import android.content.Context;

import boaventura.com.devel.br.flutteraudioquery.loaders.tasks.AbstractLoadTask;
import io.flutter.plugin.common.MethodChannel;

public abstract class AbstractLoader {
    static final String TAG_ERROR = "ERROR";

    private final ContentResolver m_resolver;
    static final int QUERY_TYPE_DEFAULT = 0x00;

    AbstractLoader(final Context context){
        m_resolver = context.getContentResolver();
    }

    final ContentResolver getContentResolver(){ return m_resolver; }

    /**
     * This method should create a new background task to run SQLite queries and return
     * the task.
     * @param result
     * @param selection
     * @param selectionArgs
     * @param sortOrder
     * @param type An integer number that can be used to identify what kind of task do you want
     *             to create.
     * @return
     */
    protected abstract AbstractLoadTask createLoadTask(final MethodChannel.Result result, final String selection,
                                         final String[] selectionArgs, String sortOrder, final int type );



}
